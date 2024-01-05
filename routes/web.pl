#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use Http::Route;
use Hangman::Http::Controllers::Controller;
use Hangman::GamestateRepository;
use Foundation::Appify;

Http::Route::group({

    middlewares => [

        # Check if the visitor is signed in.
        'Http::Middlewares::Auth',
        
        # TODO: Implement service middleware classes instead of only using
        # TODO: closures.
        sub {
            my $request = shift;
            my $next = shift;

            return &$next($request); 
        }

    ],

}, sub {

    # Routes within this scope require the visitor to be signed in.

    Http::Route::group({

        # The prefix of the http route.
        prefix => '/apps/hangman',

        # The prefix of the route name.
        as => 'apps.hangman.',

    }, sub {
        
        Http::Route::get('/', sub {

            my $request = shift;

            # TODO: Implement default controller routing instead of creating
            # TODO: an instance of the controller class.

            return Hangman::Http::Controllers::Controller->new()->welcome(
                $request,
            );

        }),
        

        Http::Route::get('/messages/{id}', sub {

            my $request = shift;

            return Hangman::Http::Controllers::Controller->new()->showMessage(
                $request,
            );

        }),

        Http::Route::group({

            # The prefix of the http route.
            prefix => '/admin',

            # The prefix of the route name.
            as => 'admin.',

            middlewares => [

                sub {
                    my $request = shift;
                    my $next = shift;
                    
                    unless (user()->isHangmanAdmin()) {
                        abort('Unauthorized.', 403);
                    }

                    return &$next($request); 
                },

            ],

        }, sub {
            
            Http::Route::get('/', sub {

                my $request = shift;

                return Hangman::Http::Controllers::Controller->new()->dashboard(
                    $request,
                );

            }),

        }),
        Http::Route::group({
            middlewares => [
                # Ensure active Gamestate
                sub {
                    my $request = shift;
                    my $next = shift;
                    
                    my $userID = user()->get('id');
                    unless ($userID) {
                        die "Cant play without being logged in!";
                    }

                    my $repo = Hangman::GamestateRepository->new();
                    my $gamestate = $repo->findByUserId($userID);

                    unless($gamestate) {
                        $gamestate = $repo->startNewGameForUser($userID);
                        $gamestate->saveInDB($repo->{controller});
                    } 
                    
                    $request->{gamestate} = $gamestate;
                    $request->{gamestaterepo} = $repo;

                    my $template = &$next($request);

                    if ($request->{gamestate}->isWon() or ($request->{gamestate}->{remaining_guesses} <= 0)) {
                        $repo->startNewGameForUser($userID);
                    }
                    if ($request->{gamestate}->isWon()) {
                        $request->{gamestate}->saveAsHighscore($repo->{controller});
                    }
                    return $template;
                },
                # Check for and process Guess
                sub {
                    my $request = shift;
                    my $next = shift;

                    my $params = \%{$request->Vars};
                    my $guess = $params->{guess};
                    my $repo = $request->{gamestaterepo};
                    my $gamestate = $request->{gamestate};

                    if($guess && index(lc($gamestate->{guessed_characters}), lc($guess)) == -1) {
                        my $guesses = $gamestate->{guessed_characters};
                        $gamestate->{guessed_characters} = $guesses . lc($guess);
                        if (index(lc($gamestate->{word_to_guess}), lc($guess)) == -1) {
                            $gamestate->{remaining_guesses} = $gamestate->{remaining_guesses} - 1;
                        }
                        $gamestate->saveInDB($repo->{controller});
                    }
                    $request->{gamestate} = $gamestate;

                    return &$next($request); 
                },
                

            ],

        }, sub {
            
            Http::Route::get('/play', sub {

                my $request = shift;

                return Hangman::Http::Controllers::Controller->new()->play(
                    $request,
                );

            }),

        }),

    });

});

# Http::Route::get('/play', sub {

#             my $request = shift;

#             # TODO: Implement default controller routing instead of creating
#             # TODO: an instance of the controller class.

#             return Hangman::Http::Controllers::Controller->new()->play(
#                 $request,
#             );

#         }),