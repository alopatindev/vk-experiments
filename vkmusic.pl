#!/usr/bin/perl

# creates a directory with bandname, downloads it from vk.com, updates idv3-tags
# FIXME: support UTF-8

#use Data::Printer;
use VKontakte::Standalone;
use utf8;
my $vk = new VKontakte::Standalone:: "1973922";

my $query = $ARGV[0];
if (length($query) == 0) {
    print "syntax: $0 'Porcupine Tree'";
    exit;
}

print "creating dir $query\n";
mkdir($query);
chdir($query);

my $auth_uri = $vk->auth_uri("audio");
print "$auth_uri\n";

system(('chromium-anon', $auth_uri));
print "allow permissions and put a redirection link: ";
my $where = <STDIN>;
#my $where = 'https://oauth.vk.com/blank.html#access_token=...';

$vk->redirected($where);

print "querying $query...\n";

my $results = $vk->api("audio.search", {q => $query});
my $lquery = lc($query);
my @downloaded_songs = ();

for $song (@{$results}) {
    my $artist = $song->{'artist'};
    my $title = $song->{'title'};
    my $url = $song->{'url'};

    my $ltitle = lc($title);
    if ((lc($artist) eq $lquery) && !($ltitle ~~ @downloaded_songs)) {
        my $filename = "$query - $title.mp3";
        print "downloading $filename... ";
        system(('wget', $url, '-qcO', $filename));
        print "ok\n";
        system(('mid3iconv', '-q', '--remove-v1', '-eCP1251', $filename));
        system(('id3tag', "--artist=$query", $filename));
        push(@downloaded_songs, $ltitle);
    }
}
