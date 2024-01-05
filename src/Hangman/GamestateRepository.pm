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
    my $userid = user()->get('id');

    my $newGamestate = Hangman::Gamestate->new(
        undef,
        $userid,
        10,
        10,
        $self->chooseWord(),
        ''
    );
    my $currentGameState = Hangman::Gamestate->fromUserID($userid, $self->{controller});
    if($currentGameState) {
        $currentGameState->delete($self->{controller});
    }

    return $newGamestate->saveInDB($self->{controller});
}

sub chooseWord {
    return 'HalloWelt';
}

1;