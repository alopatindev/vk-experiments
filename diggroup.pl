#!/usr/bin/perl

use Data::Printer;
use VKontakte::Standalone;

my $APP_ID = '1973922';

#my $GROUP_ID = 'fair_elections';
#my $GROUP_ID = 'brendetc';
#my $GROUP_ID = 'kk_bezymie';
my $GROUP_ID = '935610';

my $vk = new VKontakte::Standalone:: $APP_ID;
my $auth_uri = $vk->auth_uri('groups,friends');
print $auth_uri;

print "\nauthorizing... ";

#my $auth_uri = $vk->auth_uri("audio");
#system(('chromium-anon', $auth_uri));
#print "input redirect link:";
#my $where = <STDIN>;
my $where = 'https://oauth.vk.com/blank.html#access_token=6a60c95ebd6180e7f325bc0997278a8735a7cf52523b6f37826ed589d9e3ea4172f0205a8bef4f0447e7a&expires_in=86400&user_id=156993436';

$vk->redirected($where);

print "ok\n";

my $page_max = 1000;
my $offset = 0;
my $results = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
my $count = $results->{count};
my $members = ();
push(@members, @{$results->{users}});

while (scalar(@members) + 1 < $count) { # FIXME: check this
#while ($count > 0) {
    $offset += $page_max;
    $results = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
    $count = $results->{count};
    push(@members, @{$results->{users}});
    #p $results->{'users'};
    print "OFFSET=$offset $#members < $count "; print scalar(@members),"\n\n";
}

#print "SCALAR=";
#print scalar(@members),"\n\n";

# counting friends
foreach $member0 (@members) {
    foreach $member1 (@members) {
        if ($member0 != $member1) {
            print "areFriends($member0,$member1)\n";
            $result = $vk->api("friends.areFriends", {uids => "$member0,$member1"});
            #print "friends=", @{$result}[1]->{friend_status},"\n";# == 3, "\n";
            my $are_friends = @{$result}[0]->{friend_status} == 3 ||
                              @{$result}[1]->{friend_status} == 3;
            if ($are_friends) {
            } else {
            }
        }
    }
    print "\n";
}
