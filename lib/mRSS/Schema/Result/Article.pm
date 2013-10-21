use utf8;
package mRSS::Schema::Result::Article;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mRSS::Schema::Result::Article

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::InflateColumn::DateTime::Duration>

=back

=cut

__PACKAGE__->load_components(
  "InflateColumn::DateTime",
  "TimeStamp",
  "InflateColumn::DateTime::Duration",
);

=head1 TABLE: C<articles>

=cut

__PACKAGE__->table("articles");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'articles_id_seq'

=head2 feed

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 1

=head2 title

  data_type: 'text'
  is_nullable: 1

=head2 link

  data_type: 'text'
  is_nullable: 1

=head2 description

  data_type: 'text'
  is_nullable: 1

=head2 imported

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 read_date

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 read

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=head2 issued

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 modified

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 favorite

  data_type: 'boolean'
  default_value: false
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "articles_id_seq",
  },
  "feed",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 1 },
  "title",
  { data_type => "text", is_nullable => 1 },
  "link",
  { data_type => "text", is_nullable => 1 },
  "description",
  { data_type => "text", is_nullable => 1 },
  "imported",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "read_date",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "read",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
  "issued",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "modified",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "favorite",
  { data_type => "boolean", default_value => \"false", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<articles_subscription_key>

=over 4

=item * L</feed>

=item * L</title>

=item * L</link>

=back

=cut

__PACKAGE__->add_unique_constraint("articles_subscription_key", ["feed", "title", "link"]);

=head1 RELATIONS

=head2 feed

Type: belongs_to

Related object: L<mRSS::Schema::Result::Feed>

=cut

__PACKAGE__->belongs_to(
  "feed",
  "mRSS::Schema::Result::Feed",
  { id => "feed" },
  {
    is_deferrable => 0,
    join_type     => "LEFT",
    on_delete     => "NO ACTION",
    on_update     => "NO ACTION",
  },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-09-19 22:56:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:pv3VRcFUTdteCD8aUYtGMQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
