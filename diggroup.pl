#!/usr/bin/perl

# this script shows number of common friends in one group for every group member

#use Data::Printer;
use VKontakte::Standalone;

local $SIG{__WARN__} = sub {};

autoflush STDOUT;

my $APP_ID = '1973922';
my $GROUP_ID = 'fair_elections';

my $vk = new VKontakte::Standalone:: $APP_ID;
my $auth_uri = $vk->auth_uri('groups,friends');
print $auth_uri;
print "authorizing";

system(('chromium-anon', $auth_uri));
print "allow permissions and put a redirection link:";
my $where = <STDIN>;
#my $where = 'https://oauth.vk.com/blank.html#access_token=...';

$vk->redirected($where);

my $page_max = 1000;
my $offset = 0;
my $r = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
my $count = $r->{count};
my $members = ();
push(@members, @{$r->{users}});

while (scalar(@members) + 1 < $count) {
    $offset += $page_max;
    $r = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
    $count = $r->{count};
    push(@members, @{$r->{users}});
    print "OFFSET=$offset $#members < $count "; print scalar(@members),"\n";
}

# counting friends
foreach $member (@members) {
    $r = $vk->api("friends.get", {uid => "$member"});
    my $friends = ($r);
    my $friends_number = 0;
    foreach $friend (@{$friends}) {
        if ($friend ~~ @members) {
            $friends_number++;
        }
    }

    $r = $vk->api("users.get", {uids => "$member", fields => "first_name,last_name"});

    my $member_first_name = @{$r}[0]->{first_name};;
    my $member_last_name = @{$r}[0]->{last_name};;

    print "$friends_number\t";
    print "$member_first_name\t";
    print "$member_last_name\t";
    print "http://vk.com/id$member\n";
}
