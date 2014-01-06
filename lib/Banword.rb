class Banword

    def initialize ()
        @@badWords = ["merda", "porra", "merd4", "caralho", "g1", "globo"]
    end

    def clean (phrase)

        seperated_words = phrase.split(" ")
        cleaned_string = ""

        for word in seperated_words
            cleaned_string << cleanWord(word)
        end

        return cleaned_string
    end

    private

    def cleanWord (word)
        @@badWords.each do |bad_word|
            if word.downcase == bad_word.to_s
                word = bad_word.to_s[0]+'****'
            end
        end
        return word + "  "
    end
end
