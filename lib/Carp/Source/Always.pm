package Carp::Source::Always;

use strict;
use warnings;
use Carp::Source;


our $VERSION = '0.03';


our %options;


sub import {
    my $class = shift;
    %options = @_;
}


sub _warn {
  if ($_[-1] =~ /\n$/s) {
    my $arg = pop @_;
    $arg =~ s/ at .*? line .*?\n$//s;
    push @_, $arg;
  }
  $Carp::Source::CarpLevel = 1;
  warn Carp::Source::longmess_heavy(join('', grep { defined } @_), %options);
}


sub _die {
  if ($_[-1] =~ /\n$/s) {
    my $arg = pop @_;
    $arg =~ s/ at .*? line .*?\n$//s;
    push @_, $arg;
  }
  $Carp::Source::CarpLevel = 1;
  die Carp::Source::longmess_heavy(join('', grep { defined } @_), %options);
}

my %OLD_SIG;

BEGIN {
  @OLD_SIG{qw(__DIE__ __WARN__)} = @SIG{qw(__DIE__ __WARN__)};
  $SIG{__DIE__} = \&_die;
  $SIG{__WARN__} = \&_warn;
}

END {
  no warnings 'uninitialized';
  @SIG{qw(__DIE__ __WARN__)} = @OLD_SIG{qw(__DIE__ __WARN__)};
}

1;
__END__

=head1 NAME

Carp::Source::Always - Warns and dies with stack backtraces and source code context

=head1 SYNOPSIS

  use Carp::Source::Always;

makes every C<warn()> and C<die()> complains loudly, with source code context
like L<Carp::Source>, in the calling package and elsewhere. More often used on
the command line:

  perl -MCarp::Source::Always script.pl

=head1 DESCRIPTION

This module is meant as a debugging aid. It can be used to make a script
complain loudly with stack backtraces and source code context when
C<warn()>ing or C<die()>ing.

You can specify the same options as L<Carp::Source>'s C<source_cluck()> takes,
separated by commas. For example:

    perl -MCarp::Source::Always=lines,5,color,'yellow on_blue' script.pl

It does not work for one-liners because there is no file from which to load
source code.

This module does not play well with other modules which fusses around with
C<warn>, C<die>, C<$SIG{'__WARN__'}>, C<$SIG{'__DIE__'}>.

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

