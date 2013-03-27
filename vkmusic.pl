#!/usr/bin/perl

# creates a directory with bandname, downloads it from vk.com, updates idv3-tags

#use Data::Printer;
use VKontakte::Standalone;
use Encode;

sub d {
    return decode('utf8', $_[0]);
}

my $vk = new VKontakte::Standalone:: "1973922";

my $query = $ARGV[0];
if (length($query) == 0) {
    print "syntax: $0 'Porcupine Tree'";
    exit;
}

print "creating dir $query\n";
mkdir($query);
chdir($query);
my $q = d($query);

my $auth_uri = $vk->auth_uri('audio');
print "$auth_uri\n";

system(('chromium', $auth_uri));
print "allow permissions and put a redirection link: ";
my $where = <STDIN>;
#my $where = 'https://oauth.vk.com/blank.html#access_token=...';

$vk->redirected($where);

my $results = $vk->api('audio.search', {q => $query, count => 200});
my $lquery = lc($q);
my @downloaded_songs = ();

for $song (@{$results}) {
    my $artist = $song->{'artist'};
    my $title = $song->{'title'};
    $title =~ s/^\s+|\s+$//g;
    my $url = $song->{'url'};

    my $ltitle = lc($title);
    if ((lc($artist) eq $lquery) && !($ltitle ~~ @downloaded_songs)) {
        my $filename = "$q - $title.mp3";
        print "downloading $filename... ";
        system(('wget', $url, '-qcO', $filename));
        system(('mid3iconv', '-q', '--remove-v1', '-eCP1251', $filename));
        system(('mid3v2-2.7', '-C', '-a', $q, '-t', $title, $filename));
        print "ok\n\n";
        push(@downloaded_songs, $ltitle);
    }
}
