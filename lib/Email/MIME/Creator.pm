package Email::MIME::Creator;
# $Id: Creator.pm,v 1.3 2004/09/25 15:37:21 cwest Exp $
use strict;

use vars qw[$VERSION];
$VERSION = (qw$Revision: 1.3 $)[1];

use base q[Email::Simple::Creator];

package Email::MIME;
use strict;

use vars qw[$CREATOR];
$CREATOR = 'Email::MIME::Creator';

use Email::MIME::Modifier;

sub create {
    my ($class, %args) = @_;

    my $header = '';
    my %headers;
    if ( exists $args{header} ) {
        my @headers = @{ $args{header} };
        pop @headers if @headers % 2 == 1;
        while ( my ($key, $value) = splice @headers, 0, 2 ) {
            $headers{$key} = 1;
            $CREATOR->_add_to_header(\$header, $key, $value);
        }
    }
    $CREATOR->_add_to_header(\$header,
      Date => $CREATOR->_date_header
    ) unless $headers{Date};
    $CREATOR->_add_to_header(\$header,
      'MIME-Version' => '1.0',
    );

    my $email = $class->new($header);

    my %attrs = $args{attributes} ? %{$args{attributes}} : ();
    foreach ( qw[content_type charset name format boundary
                 encoding
                 disposition filename] ) {
        my $set = "$_\_set";
        $email->$set( $attrs{$_} ) if exists $attrs{$_};
    }

    if ( $args{parts} && @{$args{parts}} ) {
       $email->parts_set( $args{parts} );
    } elsif ( exists $args{body} ) {
       $email->body_set( $args{body} );
    }
    
    $email;
}

1;

__END__

=head1 NAME

Email::MIME::Creator - Email::MIME constructor for starting anew.

=head1 SYNOPSIS

  use Email::MIME;
  use Email::MIME::Creator;
  use IO::All;

  # multipart message
  my @parts = (
      Email::MIME->create(
          attributes => {
              filename     => "report.pdf",
              content_type => "application/pdf",
              encoding     => "quoted-printable",
              name         => "2004-financials.pdf",
          },
          body => io( "2004-financials.pdf" )->slurp,
      ),
      Email::MIME->create(
          attributes => {
              content_type => "text/plain",
              disposition  => "attachment",
              charset      => "US-ASCII",
          },
          body => "Hello there!",
      ),
  );

  my $email = Email::MIME->create(
      header => [ From => 'casey@geeknest.com' ],
      parts  => [ @parts ],
  );

  # nesting parts
  $email->parts_set(
      [
        $email->parts,
        Email::MIME->create( parts => [ @parts ] ),
      ],
  );
  
  # standard modifications
  $email->header_set( 'X-PoweredBy' => 'RT v3.0'      );
  $email->header_set( To            => rcpts()        );
  $email->header_set( Cc            => aux_rcpts()    );
  $email->header_set( Bcc           => sekrit_rcpts() );

  # more advanced
  $_->encoding_set( 'base64' ) for $email->parts;
  
  print $email->as_string;
  
  *rcpts = *aux_rcpts = *sekrit_rcpts = sub { 'you@example.com' };

=head1 DESCRIPTION

=head2 Methods

=over 5

=item create

  my $single = Email::MIME->create(
    header     => [ ... ],
    attributes => { ... },
    body       => '...',
  );
  
  my $multi = Email::MIME->create(
    header     => [ ... ],
    attributes => { ... },
    parts      => [ ... ],
  );

This method creates a new MIME part. The C<header> parameter is a lis of headers
to include in the message. C<attributes> is a hash of MIME attributes to assign
to the part, and may override portions of the header set in the C<header> parameter.

The C<parts> parameter is a list reference containing C<Email::MIME> objects. C<parts>
takes precedence over C<body>, which will set this part's body if assigned. So, multi
part messages shold use the C<parts> parameter and single part messages should use C<body>.

Back to C<attributes>. The hash keys correspond directly to methods or modifying a message
from C<Email::MIME::Modifier>. The allowed keys are: content_type, charset, name, format,
boundary, encoding, disposition, and filename. They will be mapped to C<"$attr\_set"> for
message modification.

=back

=head1 SEE ALSO

L<Email::MIME>,
L<Email::MIME::Modifier>,
L<Email::Simple::Creator>,
L<perl>.

=head1 AUTHOR

Casey West, <F<casey@geeknest.com>>.

=head1 COPYRIGHT

  Copyright (c) 2004 Casey West.  All rights reserved.
  This module is free software; you can redistribute it and/or modify it
  under the same terms as Perl itself.

=cut
