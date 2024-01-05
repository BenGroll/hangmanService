package Hangman::Http::Controllers::Controller;

use strict;
use warnings;

use Data::Dumper;
use Foundation::Appify;
use HTML::Template;



use lib join ('/', splice(@{[split(/\//, __FILE__)]}, 0, scalar @{[split(/\//, __FILE__)]} -1)) . '/../../';
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
    
    app()->pushToStack('scripts', servicePath('hangman') . '/script.js');
    
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

sub getFolder {
    return join ('/', splice(@{[split(/\//, __FILE__)]},
        0, 
        scalar @{[split(/\//, __FILE__)]} -1)) . "/";
}

1;
