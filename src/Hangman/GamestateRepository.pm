package Hangman::GamestateRepository;

use strict;
use warnings;

use Data::Dumper;
use Hangman::Gamestate;
use Foundation::Appify;


sub new {
    my $class = shift;

    my @driver_names = DBI->available_drivers;
    my $driver = "mysql";
    my $database = "cs_bens_database";
    my $dsn = "DBI:$driver:database=$database";
    my $db = DBI->connect($dsn, 'root', 'admin') or die $DBI::errstr;
    my $self = {controller => $db, tablename => "gamestates"};

    bless($self, $class);
}

sub findByUserId {
    my $self = shift;
    my $userid = shift;
    return Hangman::Gamestate->fromUserID($userid, $self->{controller});
}

sub startNewGameForUser {
    my $self = shift;
    my $difficulty = shift;

    my $userid = user()->get('id');

    my $newGamestate = Hangman::Gamestate->new(
        undef,
        $userid,
        $difficulty,
        $difficulty,
        $self->chooseWordOfLength($difficulty),
        ''
    );
    my $currentGameState = Hangman::Gamestate->fromUserID($userid, $self->{controller});
    if($currentGameState) {
        $currentGameState->delete($self->{controller});
    }

    return $newGamestate->saveInDB($self->{controller});
}

sub chooseWordOfLength {
    my $self = shift;
    my $length = shift or die "No Word Length Specified!";
    my $file = getFolder() . 'wortliste.txt';
    open my $info, $file or die 'Could not open $file: $!';

    my @words = ();
    while (my $word = <$info>) {
        chomp($word);
        my $wordL = scalar split(//, $word);
        if($wordL == $length) {
            push(@words, $word);
        }
    }
    close $info;
    my $wordidx = rand(scalar @words);
    my $word = @words[$wordidx];  
    return $word;
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}

1;