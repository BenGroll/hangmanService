package Hangman::Http::Controllers::Controller;

use strict;
use warnings;

use Data::Dumper;
use Foundation::Appify;
use HTML::Template;

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}

use lib getFolder() . '../../';
use Hangman::GamestateRepository;

sub new {
    my $class = shift;

    my $self = {};
    bless $self, $class;

    return $self;
}

sub welcome {
    my $self = shift;
    my $request = shift;

    app()->pushToStack('scripts', servicePath('hangman') . '/script.js');

    my $playbutton = HTML::Template->new(filename => getFolder() . '../../../../templates/components/playbutton.tmpl');

    my $template = &_::template('hangman::welcome', {
        email => user()->get('email'),
        content => $playbutton->output(),
    });

    return $template->output();
}

sub play {
    my $self = shift;
    my $request = shift;

    my $gamestate = $request->{gamestate};
    my $repo = $request->{gamestaterepo};

    app()->pushToStack('scripts', servicePath('hangman') . '/script.js');

       
    my $params = \%{$request->Vars};
    my $guess = $params->{guess};
    
    if($guess) {
        my $guesses = $gamestate->{guessed_characters};
        if (index(lc($gamestate->{guessed_characters}), lc($guess)) == -1) {
            $gamestate->{guessed_characters} = $guesses . lc($guess);
            if (index(lc($gamestate->{word_to_guess}), lc($guess)) == -1) {
                $gamestate->{remaining_guesses} = $gamestate->{remaining_guesses} - 1;
            }
            $gamestate->saveInDB($repo->{controller});
        }
    }

    my $template = &_::template('hangman::welcome', {
        email => user()->get('email'),
        content => $gamestate->template()->output(),
    });

    return $template->output();

}

sub dashboard {
    my $self = shift;
    my $request = shift;

    # TODO: Do something useful.

    app()->pushToStack('scripts', servicePath('hangman') . '/script.js');

    my $template = &_::template('hangman::dashboard', {
        #
    });

    return $template->output();
}

sub showMessage {
    my $self = shift;
    my $request = shift;

    # TODO: Do something useful.

    return $self->welcome($request);
}



1;
