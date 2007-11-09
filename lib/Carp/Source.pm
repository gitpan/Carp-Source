package Carp::Source;

use strict;
use warnings;
use utf8;
use Term::ANSIColor;


our $VERSION = '0.01';


use base 'Exporter';


our %EXPORT_TAGS = (
    util  => [ qw(source_cluck) ],
);


our @EXPORT_OK = @{ $EXPORT_TAGS{all} = [ map { @$_ } values %EXPORT_TAGS ] };


our ($CarpLevel, $MaxArgNums, $MaxEvalLen, $MaxArgLen, $Verbose);


# If a string is too long, trims it with ...
sub str_len_trim {
  my $str = shift;
  my $max = shift || 0;
  if (2 < $max and $max < length($str)) {
    substr($str, $max - 3) = '...';
  }
  return $str;
}


# Transform an argument to a function into a string.
sub format_arg {
  my $arg = shift;
  if (ref($arg)) {
      $arg = defined($overload::VERSION) ? overload::StrVal($arg) : "$arg";
  }elsif (not defined($arg)) {
    $arg = 'undef';
  }
  $arg =~ s/'/\\'/g;
  $arg = str_len_trim($arg, $MaxArgLen);
  
  # Quote it?
  $arg = "'$arg'" unless $arg =~ /^-?[\d.]+\z/;

  # The following handling of "control chars" is direct from
  # the original code - it is broken on Unicode though.
  # Suggestions?
  utf8::is_utf8($arg)
    or $arg =~ s/([[:cntrl:]]|[[:^ascii:]])/sprintf("\\x{%x}",ord($1))/eg;
  return $arg;
}   


# Takes the info from caller() and figures out the name of
# the sub/require/eval
sub get_subname {
  my $info = shift;
  if (defined($info->{evaltext})) {
    my $eval = $info->{evaltext};
    if ($info->{is_require}) {
      return "require $eval";
    }
    else {
      $eval =~ s/([\\\'])/\\$1/g;
      return "eval '" . str_len_trim($eval, $MaxEvalLen) . "'";
    }
  }
    
  return ($info->{sub} eq '(eval)') ? 'eval {...}' : $info->{sub};
} 


sub caller_info {
  my $i = shift(@_) + 1;
  package DB;
  my %call_info;
  @call_info{
    qw(pack file line sub has_args wantarray evaltext is_require)
  } = caller($i);

  unless (defined $call_info{pack}) {
    return ();
  }

  my $sub_name = Carp::Source::get_subname(\%call_info);
  if ($call_info{has_args}) {
    my @args = map {Carp::Source::format_arg($_)} @DB::args;
    if ($MaxArgNums and @args > $MaxArgNums) { # More than we want to show?
      $#args = $MaxArgNums;
      push @args, '...';
    }
    # Push the args onto the subroutine
    $sub_name .= '(' . join (', ', @args) . ')';
  }
  $call_info{sub_name} = $sub_name;
  return wantarray() ? %call_info : \%call_info;
}

sub longmess_heavy {
  return @_ if ref($_[0]); # don't break references as exceptions
  return ret_backtrace(0, @_);
}

# Returns a full stack backtrace starting from where it is
# told.
sub ret_backtrace {
  my ($i, @error) = @_;
  my $mess;
  my $err = join '', @error;
  $i++;

  my $tid_msg = '';
  if (defined &Thread::tid) {
    my $tid = Thread->self->tid;
    $tid_msg = " thread $tid" if $tid;
  }

  my %i = caller_info($i);
  $mess = "$err at $i{file} line $i{line}$tid_msg\n";

  while (my %i = caller_info(++$i)) {
      my $context = get_context($i{file}, $i{line});
      print $context;
      $mess .= "\t$i{sub_name} called at $i{file} line $i{line}$tid_msg\n";
  }

  return $mess;
}


sub get_context {
    my ($file, $line) = @_;
    open my $fh, '<', $file or die "can't open $file: $!\n";
    chomp(my @lines = <$fh>);
    close $fh or die "can't close $file: $!\n";

    # make calculations easier by having line 1 at element 1
    unshift @lines => '';

    my $CONTEXT = 3;

    my $min_line = $line - $CONTEXT;
    $min_line = 0 if $min_line < 0;

    my $max_line = $line + $CONTEXT;

    my $format = sprintf '%%%dd' => length($max_line);

    my $source = "context for $file line $line:\n\n";

    for my $c_line ($min_line .. $line - 1) {
        next unless defined $lines[$c_line];
        $source .= sprintf "$format: %s\n", $c_line, $lines[$c_line];
    }

    $source .= sprintf "$format: %s\n", $line,
        colored [ 'black on_yellow' ], $lines[$line];

    for my $c_line ($line + 1 .. $max_line) {
        next unless defined $lines[$c_line];
        $source .= sprintf "$format: %s\n", $c_line, $lines[$c_line];
    }

    $source .= ('=' x 75) . "\n";
    $source;
}


sub source_cluck { warn longmess_heavy(@_) }



1;


__END__

=head1 NAME

Carp::Source - warn of errors with stack backtrace and source context

=head1 SYNOPSIS

    use Carp::Source 'source_cluck';
    source_cluck 'some error';

=head1 DESCRIPTION

This module exports one function, C<source_cluck()>. It is like L<Carp>'s
C<cluck()>, but it also displays the source code context of all call frames,
with three lines before and after each call being shown, and the call
being highlighted.

This is just a quick hack - not all of C<Carp>'s or even just C<cluck()>'s
features are present. The code borrows heavily from C<Carp>.

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<carpsource> tag.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-carp-source@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

