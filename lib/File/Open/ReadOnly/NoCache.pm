package File::Open::ReadOnly::NoCache;

# Author Nigel Horne: njh@bandsman.co.uk
# Copyright (C) 2019 Nigel Horne

# Usage is subject to licence terms.
# The licence terms of this software are as follows:
# Personal single user, single computer use: GPL2
# All other users (including Commercial, Charity, Educational, Government)
#	must apply in writing for a licence for use from Nigel Horne at the
#	above e-mail.

use strict;
use warnings;
use IO::AIO;

=head1 NAME

File::Open::ReadOnly::NoCache - Open a file and clear the cache afterward

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.02';

=head1 SUBROUTINES/METHODS

=head2 Open::ReadOnly::NoCache

Open a file and flush the cache afterwards.

    use File::Open::ReadOnly::NoCache;
    my $fh = File::Open::ReadOnly::NoCache('/tmp/foo');

=cut

sub File::Open::ReadOnly::NoCache {
	my $proto = shift;
	my $class = ref($proto) || $proto;

	return unless(defined($class));

	my %params;
	if(ref($_[0]) eq 'HASH') {
		%params = %{$_[0]};
	} elsif(scalar(@_) % 2 == 0) {
		%params = @_;
	} else {
		$params{'filename'} = shift;
	}

	my $filename = $params{'filename'};

	open(my $fd, '<', $filename);
	return bless { fd => $fd }, $class
}

sub DESTROY {
	if(defined($^V) && ($^V ge 'v5.14.0')) {
		return if ${^GLOBAL_PHASE} eq 'DESTRUCT';	# >= 5.14.0 only
	}
	my $self = shift;

	my $fd = $self->{'fd'};
	my @statb = stat($fd);
	my $size = $statb[7];
	IO::AIO::fadvise($fd, 0, $statb[7], IO::AIO::FADV_DONTNEED);

	close $self->{'fd'};
}

=head1 AUTHOR

Nigel Horne, C<< <njh at bandsman.co.uk> >>

=head1 BUGS

Please report any bugs or feature requests to
C<bug-file-Open::ReadOnly::NoCache at rt.cpan.org>,
or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=File-Open::ReadOnly::NoCache>.
I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc File::Open::ReadOnly::NoCache

You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=File-Open::ReadOnly::NoCache>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/File-Open::ReadOnly::NoCache>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/File-Open::ReadOnly::NoCache>

=item * Search CPAN

L<http://search.cpan.org/dist/File-Open::ReadOnly::NoCache/>

=back

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Nigel Horne.

Usage is subject to licence terms.

The licence terms of this software are as follows:

* Personal single user, single computer use: GPL2
* All other users (including Commercial, Charity, Educational, Government)
  must apply in writing for a licence for use from Nigel Horne at the
  above e-mail.

=cut

1;