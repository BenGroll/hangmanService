-- @block Create Gamestates Table
DROP TABLE IF EXISTS gamestates;
CREATE TABLE gamestates (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    total_guesses INT NOT NULL,
    remaining_guesses INT,
    word_to_guess VARCHAR(255) NOT NULL,
    guessed_characters VARCHAR(255)
);
INSERT INTO gamestates 
    (id,    user_id,    total_guesses,  remaining_guesses,  word_to_guess,  guessed_characters) VALUES 
    (1,     1,          10,             10,                 'HalloWelt',    ''              );