package mRSS::Scrub;

use HTML::Parser ();

# This is from HTML::Parser eg/hstrip

# configure these values
my @ignore_attr = qw(bgcolor background color face style link alink vlink text
  onblur onchange onclick ondblclick onfocus onkeydown onkeyup onload
  onmousedown onmousemove onmouseout onmouseover onmouseup
  onreset onselect onunload
);
my @ignore_tags     = qw(font big small);
my @ignore_elements = qw(script style);

# make it easier to look up attributes
my %ignore_attr = map { $_ => 1 } @ignore_attr;

my $scrubbed = '';

sub _tag {
	my ( $pos, $text ) = @_;
	my $string = $text;

	if ( @$pos >= 4 ) {

		# kill some attributes
		my ( $k_offset, $k_len, $v_offset, $v_len ) = @{$pos}[ -4 .. -1 ];
		my $next_attr = $v_offset ? $v_offset + $v_len : $k_offset + $k_len;
		my $edited;
		while ( @$pos >= 4 ) {
			( $k_offset, $k_len, $v_offset, $v_len ) = splice @$pos, -4;
			if ( $ignore_attr{ lc substr( $string, $k_offset, $k_len ) } ) {
				substr( $string, $k_offset, $next_attr - $k_offset ) = "";
				$edited++;
			}
			$next_attr = $k_offset;
		}

		# if we killed all attributed, kill any extra whitespace too
		$string =~ s/^(<\w+)\s+>$/$1>/ if $edited;
	}
	$scrubbed .= $string;
}

sub _decl {
	my $type = shift;
	$scrubbed .= shift if $type eq "doctype";
}

sub _text {
	$scrubbed .= shift;
}


sub scrub {
	my $self = shift;
	my $html = shift;
	return if !defined($html);
	$scrubbed = '';
	my $p = HTML::Parser->new(
		api_version   => 3,
		start_h       => [ \&_tag, "tokenpos, text" ],
		process_h     => [ "", "" ],
		comment_h     => [ "", "" ],
		declaration_h => [ \&_decl, "tagname, text" ],
		default_h     => [ \&_text, "text" ],

		ignore_tags     => \@ignore_tags,
		ignore_elements => \@ignore_elements,
	);
	$p->parse($html)->eof;
	return $scrubbed;
}

1;
