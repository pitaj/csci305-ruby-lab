#!/usr/bin/ruby

###############################################################
#
# CSCI 305 - Ruby Programming Lab
#
# Peter Jaszkowiak
# p.jaszkow@gmail.com
#
###############################################################

$name = "Peter Jaszkowiak"

def cleanup_title(line)
	# extract song title from a<SEP>b<SEP>author<SEP>title
	title = line.split(/<SEP>/).last
	# eliminate superfluous text
	title = title.split(/(?:feat\.)|[(\[{\\\/_\-:"`+=*]/)[0]
	# delete punctuation
	title = title.gsub(/[\?¿!¡\.;&@%#\|\n]/, "")
	# lowercase title
	title = title.downcase
	# filter out common stop words
	title = title.split(' ').select { |item| ![
		'a',
		'an',
		'and',
		"by",
		"for",
		"from",
		"in",
		"of",
		"on",
		"or",
		"out",
		"the",
		"to",
		"with",
].include? item }

	title.join(' ')
end

$bigrams = Hash.new # The Bigram data structure

# create new storage class for two words


# bigrams stored in a hash of hashes
# each word gets mapped to a hash
# of words to the number of times that word appears after
def add_to_bigrams(title)
	# split title into separate words
	split = title.split(/ /)

	# iterate over each pair
	(0..(split.length - 2)).each do |i|
		word, after = split.slice(i, i + 2)
		
		if $bigrams[word] == nil
			$bigrams[word] = Hash.new
			$bigrams[word].default = 0
		end

		$bigrams[word][after] += 1
	end
end

# replace the sub-hashes with the single most common word for each
def finalize_bigrams
	$bigrams.each do |previous, subhash|
		most = 0
		mostWord = nil

		subhash.each do |after, count|
			if count > most
				most = count
				mostWord = after
			end
		end

		$bigrams[previous] = mostWord
	end
end

# function to process each line of a file and extract the song titles
def process_file(file_name)
	puts "Processing File.... "

	count = 0

	begin
		IO.foreach(file_name, encoding: "utf-8") do |line|
			title = cleanup_title(line)

			# only add to data if contains only English characters
			if title =~ /^[\d\w\s']+$/
				count += 1

				add_to_bigrams(title)
			end
		end

		# finalize_bigrams()

		puts "Finished. Bigram model built.\n"
		puts "Counted #{count} matching songs.\n"
	rescue
		STDERR.puts "Could not open file"
		exit 4
	end
end

# get most common word after the given previous word
def mcw(previous)
	subhash = $bigrams[previous]

	if subhash
		most = 0
		mostWord = nil

		subhash.each do |after, count|
			if count > most
				most = count
				mostWord = after
			end
		end

		mostWord
	end
end

# create a title 20 words long or less
# based on the most likely word pairs
def create_title(word)
	sentence = []

	while word && sentence.length <= 20 do
		sentence << word
		word = mcw word
	end

	sentence.join(' ')
end

# Executes the program
def main_loop()
	puts "CSCI 305 Ruby Lab submitted by #{$name}"

	if ARGV.length < 1
		puts "You must specify the file name as the argument."
		exit 4
	end

	# process the file
	process_file(ARGV[0])

	puts create_title "happy"

	puts "Generate a song title based on the first word"
	# Get user input
	while true do
		print "Enter a word [Enter 'q' to quit]: "

		# need stdio because otherwise it uses the file as input
		input = $stdin.gets.strip

		if input.downcase == 'q'
			exit 0
		end

		if input == ''
			puts "Emptiness won't work"
		else
			title = create_title(input)
			puts title
		end
	end
end

if __FILE__==$0
	main_loop()
end
