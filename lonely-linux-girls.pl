#!/usr/bin/perl

# this script shows girls from groups/communities that contain word "linux"
# with current city as spb and
# replationship status "actively searching" or "single"

use Data::Printer;
use VKontakte::Standalone;

my $APP_ID = '1973922';

local $SIG{__WARN__} = sub {};

my $GROUP_QUERY = 'linux';
my $CITY_ID = 2; #spb

open(OUT, ">$GROUP_QUERY.txt");
*STDERR = *OUT;
autoflush STDOUT;
autoflush OUT;

my $vk = new VKontakte::Standalone:: $APP_ID;
my $auth_uri = $vk->auth_uri('groups,users');

print "copy this link to browser:\n\n";
print $auth_uri;
print "\n\n";

system(('chromium', $auth_uri));
print 'allow permissions and input a redirection link: ';
my $where = <STDIN>;
#my $where = 'https://oauth.vk.com/blank.html#access_token=...';

$vk->redirected($where);

sub process_group {
    my $group_id = $_[0];
    my $page_max = 1000;
    my $offset = 0;
    my $r = $vk->api("groups.getMembers", {gid => $group_id, offset => $offset});
    my $count = $r->{count};
    my $members = ();

    push(@members, @{$r->{users}});

    while (scalar(@members) + 1 < $count) {
        my $progress = ($#members * 100.0) / $count;
        printf("processing group $group_id (%3.2f%%)\n", $progress);

        $offset += $page_max;
        $r = $vk->api("groups.getMembers", {gid => $group_id, offset => $offset});
        $count = $r->{count};
        push(@members, @{$r->{users}});
    }
    print "processing group done\n";

    checkout_members($members, $group_id);
}

sub checkout_members {
    my $members = $_[0];
    my $group_id = $_[1];
    my $i = 0;
    foreach $member (@members) {
        my $progress = ($i * 100.0) / $#members;
        printf("checking out (%3.2f%%)\n", $progress);
        $i++;

        $r = $vk->api("users.get",
            {
                uids => "$member",
                fields => "first_name,last_name,sex,online,city,relation"
            }
        );

        my $first_name = @{$r}[0]->{first_name};
        my $last_name = @{$r}[0]->{last_name};
        my $is_girl = @{$r}[0]->{sex} == 1;
        my $online = @{$r}[0]->{online} == 1 ? 'ONLINE' : 'offline';
        my $city = @{$r}[0]->{city};
        my $right_city = $city == $CITY_ID;
        my $is_single = @{$r}[0]->{relation} == 1;
        my $is_actively_searching = @{$r}[0]->{relation} == 2;
        my $right_relation = $is_single || $is_actively_seaching;
        if ($is_girl && $right_city && $right_relation) {
            print OUT "$first_name\t$last_name\t$online\t";
            print OUT "http://vk.com/id$member\thttp://vk.com/club$group_id\t";
            print OUT "$city\n";
        }
    }
}

sub find_groups {
    my $r = $vk->api("groups.search", {q => $GROUP_QUERY, count => 500});
    my $i = 0;
    my @groups = @{$r};
    foreach $group (@groups) {
        my $progress = ($i * 100.0) / $#groups;
        printf("MAIN PROGRESS (%3.2f%%)\n", $progress);
        $i++;

        my $group_id = $group->{gid};
        if (defined($group_id)) {
            print "processing http://vk.com/club$group_id\n";
            process_group($group_id);
        }
    }
}

find_groups();
close(OUT);
