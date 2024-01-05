package Hangman::Gamestate;

use strict;
use warnings;

use Data::Dumper;
use HTML::Template;

sub new {
    my $class = shift;

    my $id = shift();
    my $user_id = shift() or die "Missing Parameter userid";
    my $total_guesses = shift() or die "Missing Parameter total_guesses";
    my $remaining_guesses = shift() or 0;
    my $word_to_guess = shift() or die "Missing Parameter wordtoguess";
    my $guessed_characters = shift() or '';

    my $self = {
        id => $id,
        user_id => $user_id,
        total_guesses => $total_guesses,
        remaining_guesses => $remaining_guesses,
        word_to_guess => $word_to_guess,
        guessed_characters => $guessed_characters
    };

    bless($self, $class);
}

sub isWon {
    my $self = shift;

    my @charsToGuess = split(//, lc($self->{word_to_guess}));
    my @guessed_characters = split(//, lc($self->{guessed_characters}));
    foreach my $char (@charsToGuess) {
        unless (lc($char) ~~ @guessed_characters) {
            return 0;
        }
    }
    return 1;
}

sub values {
    my $self = shift;

    return \(
        $self->{id},
        $self->{user_id},
        $self->{total_guesses},
        $self->{remaining_guesses},
        $self->{word_to_guess},
        $self->{guessed_characters},
    );
}

sub template {
    my $self = shift;

    my $template = HTML::Template->new(filename => getFolder() . '../../templates/game.tmpl');

    my $win = $self->isWon();
    my $lose = $self->{remaining_guesses} <= 0;

    
    my $aftergamebar = '';
    if($win || $lose) {
        my $bar = HTML::Template->new(filename => getFolder() . '../../templates/components/aftergamebar.tmpl');
        $bar->param(WINORLOSE => $win, SOLUTION => $self->{word_to_guess});
        $aftergamebar = $bar->output();

    }

    $template->param(
        SCORE => "Remaining Guesses: " . $self->{remaining_guesses} . "/" . $self->{total_guesses},
        SLOTS => $self->guessSlotBar(),
        WINLOSEBAR => $aftergamebar
    );

    return $template;
}   

sub guessSlotBar {
    my $self = shift;

    my @word_to_guess = split (//, $self->{word_to_guess});
    my @guessed_characters = split ( //, $self->{guessed_characters} || '');

    my @slots = ();
    for(my $i = 0; $i < scalar (@word_to_guess); $i++) {
        my $slottemplate = HTML::Template->new(filename => getFolder() . '../../templates/components/singleguessslot.tmpl');
        if(lc(@word_to_guess[$i]) ~~ @guessed_characters ) {
            $slottemplate->param(VALUE => @word_to_guess[$i]);
        }
        my $output = $slottemplate->output();
        push(@slots, {SLOT => $output});
    }
    return \@slots;
}

sub fromUserID {
    my $class = shift;
    my $userid = shift;
    my $db = shift;
    
    my $query = "SELECT * FROM gamestates WHERE user_id = ?;";
    my $sth = $db->prepare($query);
    $sth->execute($userid);
    my $row = $sth->fetchrow_arrayref();

    unless ($row) {
        return undef;
    } else {
        return $class->new(@$row);
    }
}

sub highscoreFromUserID {
    my $class = shift;
    my $userid = shift;
    my $db = shift;
    
    my $query = "SELECT * FROM highscores WHERE user_id = ?;";
    my $sth = $db->prepare($query);
    $sth->execute($userid);
    my $row = $sth->fetchrow_arrayref();

    unless ($row) {
        return undef;
    } else {
        return $class->new(@$row);
    }
}

sub saveInDB {
    my $self = shift;
    my $db = shift or die "Missing DB to save into";

    my $testifalreadyexists = ref($self)->fromUserID($self->{user_id}, $db);
    
    my $sth;
    if($testifalreadyexists) {
        my $query = "UPDATE gamestates SET id = ?, user_id = ?, total_guesses = ?, remaining_guesses = ?, word_to_guess = ?, guessed_characters = ? WHERE id = ?;";
        $sth = $db->prepare($query);
        $sth->execute($self->{id}, $self->{user_id}, $self->{total_guesses}, $self->{remaining_guesses}, $self->{word_to_guess}, $self->{guessed_characters}, $self->{id});
    } else {
        my $query = "INSERT INTO gamestates (id, user_id, total_guesses, remaining_guesses, word_to_guess, guessed_characters) VALUES (?, ?, ?, ?, ?, ?);";
        $sth = $db->prepare($query);
        $sth->execute($self->{id}, $self->{user_id}, $self->{total_guesses}, $self->{remaining_guesses}, $self->{word_to_guess}, $self->{guessed_characters});
    }

    $self->{id} = $sth->{mysql_insertid};
    return $self;
}

sub saveAsHighscore {
    my $self = shift;
    my $db = shift or die "Missing DB to save into";

    # my $testifalreadyexists = ref($self)->highscoreFromUserID($self->{user_id}, $db);
    my $sth;
    # if($testifalreadyexists) {
    #     my $query = "UPDATE highscores SET id = ?, user_id = ?, total_guesses = ?, remaining_guesses = ?, word_to_guess = ?, guessed_characters = ? WHERE user_id = ?;";
    #     $sth = $db->prepare($query);
    #     $sth->execute($self->{id}, $self->{user_id}, $self->{total_guesses}, $self->{remaining_guesses}, $self->{word_to_guess}, $self->{guessed_characters}, $self->{user_id});
    # } else {
        my $query = "INSERT INTO highscores (id, user_id, total_guesses, remaining_guesses, word_to_guess, guessed_characters) VALUES (?, ?, ?, ?, ?, ?);";
        $sth = $db->prepare($query);
        $sth->execute($self->{id}, $self->{user_id}, $self->{total_guesses}, $self->{remaining_guesses}, $self->{word_to_guess}, $self->{guessed_characters});
    # }

    $self->{id} = $sth->{mysql_insertid};
    return $self;
}

sub delete {
    my $self = shift;
    my $db = shift or die "Missing Db to delete from";

    my $query = "DELETE FROM gamestates WHERE id = ?;";
    my $sth = $db->prepare($query);
    $sth->execute($self->{id});
}

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}



1;