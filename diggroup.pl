#!/usr/bin/perl

# this script shows number of common friends in one group for every group member

#use Data::Printer;
use VKontakte::Standalone;

my $APP_ID = '1973922';

local $SIG{__WARN__} = sub {};

print 'input group id: ';
#my $GROUP_ID = 'fair_elections';
my $GROUP_ID = <STDIN>;
chomp($GROUP_ID);

open(OUT, ">$GROUP_ID.txt");
*STDERR = *OUT;
autoflush STDOUT;
autoflush OUT;

my $vk = new VKontakte::Standalone:: $APP_ID;
my $auth_uri = $vk->auth_uri('groups,friends');

print "copy this link to browser:\n\n";
print $auth_uri;
print "\n\n";

#system(('chromium-anon', $auth_uri));
print 'allow permissions and input a redirection link: ';
my $where = <STDIN>;
#my $where = 'https://oauth.vk.com/blank.html#access_token=...';

$vk->redirected($where);

my $page_max = 1000;
my $offset = 0;
my $r = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
my $count = $r->{count};
my $members = ();

sub collect_users {
    push(@members, @{$r->{users}});

    while (scalar(@members) + 1 < $count) {
        my $progress = ($#members * 100.0) / $count;
        printf("$_[0] (%3.2f%%)\n", $progress);

        $offset += $page_max;
        $r = $vk->api("groups.getMembers", {gid => $GROUP_ID, offset => $offset});
        $count = $r->{count};
        push(@members, @{$r->{users}});
    }
    print "$_[0] done\n";
}

sub count_friends {
    my $i = 0;
    foreach $member (@members) {
        my $progress = ($i * 100.0) / $#members;
        printf("$_[0] (%3.2f%%)\n", $progress);
        $i++;

        $r = $vk->api("friends.get", {uid => "$member"});
        my $friends = ($r);
        my $friends_number = 0;
        foreach $friend (@{$friends}) {
            if ($friend ~~ @members) {
                $friends_number++;
            }
        }

        $r = $vk->api("users.get", {uids => "$member", fields => "first_name,last_name"});

        my $member_first_name = @{$r}[0]->{first_name};
        my $member_last_name = @{$r}[0]->{last_name};

        print OUT "$friends_number\t";
        print OUT "$member_first_name\t";
        print OUT "$member_last_name\t";
        print OUT "http://vk.com/id$member\n";
    }
    print "$_[0] done\n";
}

collect_users('step 1 of 2: collecting users');
count_friends('step 2 of 2: counting friends');

close(OUT);

print "done\n";
