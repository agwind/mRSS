use utf8;
package mRSS::Schema::Result::Feed;

# Created by DBIx::Class::Schema::Loader
# DO NOT MODIFY THE FIRST PART OF THIS FILE

=head1 NAME

mRSS::Schema::Result::Feed

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

=head1 TABLE: C<feeds>

=cut

__PACKAGE__->table("feeds");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0
  sequence: 'subscriptions_id_seq'

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 url

  data_type: 'text'
  is_nullable: 1

=head2 created

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 n_retrieved

  data_type: 'integer'
  is_nullable: 1

=head2 last_retrieved

  data_type: 'timestamp with time zone'
  is_nullable: 1

=head2 update_interval

  data_type: 'interval'
  is_nullable: 1

=head2 enabled

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "subscriptions_id_seq",
  },
  "name",
  { data_type => "varchar", is_nullable => 1, size => 255 },
  "url",
  { data_type => "text", is_nullable => 1 },
  "created",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "n_retrieved",
  { data_type => "integer", is_nullable => 1 },
  "last_retrieved",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "update_interval",
  { data_type => "interval", is_nullable => 1 },
  "enabled",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<subscriptions_name_key>

=over 4

=item * L</name>

=back

=cut

__PACKAGE__->add_unique_constraint("subscriptions_name_key", ["name"]);

=head1 RELATIONS

=head2 articles

Type: has_many

Related object: L<mRSS::Schema::Result::Article>

=cut

__PACKAGE__->has_many(
  "articles",
  "mRSS::Schema::Result::Article",
  { "foreign.feed" => "self.id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


# Created by DBIx::Class::Schema::Loader v0.07035 @ 2013-09-19 22:56:50
# DO NOT MODIFY THIS OR ANYTHING ABOVE! md5sum:jBz2JcVCj/gadCFs7O3NtQ


# You can replace this text with custom code or comments, and it will be preserved on regeneration
1;
