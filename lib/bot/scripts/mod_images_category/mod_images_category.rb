# Usage: `mod_images_category.rb [ABBRV] <Mod Name>` where [] is optional and <> is required
# Then simply follow the instructions.

require 'mediawiki/butt'
require 'dotenv'
Dotenv.load

# temp fix until fixed in library proper
module MediaWiki
  module Query
    module Properties
      module Pages
        # Gets all of the images in the given page.
        # @param (see #get_external_links)
        # @see https://www.mediawiki.org/wiki/API:Images MediaWiki Images API Docs
        # @since 0.8.0
        # @return [Array<String>] All of the image titles in the page.
        # @return [Nil] If the page does not exist.
        def get_images_in_page(title, limit = @query_limit_default)
          params = {
            prop: 'images',
            titles: title,
            imlimit: get_limited(limit)
          }

          query(params) do |return_val, query|
            pageid = query['pages'].keys.find { |id| id != '-1' }
            return unless pageid
            # CHANGE: Following line added as pages without images do not have an images key.
            return [] unless query['pages'][pageid].key?('images')
            return_val.concat(query['pages'][pageid]['images'].collect { |img| img['title'] })
          end
        end
      end
    end
  end
end

@wiki = MediaWiki::Butt.new('https://ftb.gamepedia.com/api.php', assertion: :bot)
@wiki.login(ENV['WIKI_USERNAME'], ENV['WIKI_PASSWORD'])

def categorize(images, mod_name)
  category = "#{mod_name} images"
  cat_link = "[[Category:#{category}]]"
  images.each do |file|
    text = @wiki.get_text(file)
    what_do = :skip
    if text == ''
      what_do = :replace
    elsif !text.nil?
      puts "#{file} has content, what would you like to do? (append, replace, skip)"
      puts "Content: #{text}"
      response = $stdin.gets.chomp
      what_do = %w(append replace skip).include?(response) ? response.to_sym : :skip
    end
    summary = "Add to #{category} category"
    fail_edit = "Failed to edit #{file}"
    case what_do
    when :skip
      puts "Skipping #{file}"
    when :replace
      puts fail_edit unless @wiki.edit(file, cat_link, summary: summary)
    when :append
      text << "\n#{cat_link}"
      puts fail_edit unless @wiki.edit(file, text, summary: summary)
    end
  end
end

def find_mod_images(mod_name)
  images = []
  @wiki.get_category_members(mod_name).each do |member|
    images.concat(@wiki.get_images_in_page(member))
  end

  images.uniq!

  ignores = File.readlines("#{__dir__}/ignores.txt").map { |line| line.chomp }
  images.delete_if { |image| ignores.include?(image) }

  images
end

has_sheet = ARGV.size == 2
mod_name = has_sheet ? ARGV[1] : ARGV[0]

images = find_mod_images(mod_name)

if has_sheet
  puts 'Please enter the sizes of the tilesheet separated by commas'
  sizes = $stdin.gets.chomp.tr(' ', '').split(',')
  sizes.each do |size|
    images << "File:Tilesheet #{ARGV[0]} #{size}.png"
  end
end

def check_correct(images, mod_name)
  puts "Found #{images.size} images. Please make sure all of these are correct. If they are, enter 'yes', if not, enter 'no' and follow the instructions"
  puts images
  puts 'Are these correct?'
  are_correct = $stdin.gets.chomp.downcase.eql?('yes')
  if are_correct
    categorize(images, mod_name)
  else
    puts 'What is incorrect?'
    puts "To make a correction to a file name, use the format 'Old File Name -> New File Name"
    puts "To add a file, use the format '+File Name+'"
    puts "To remove a file, use the format '!File Name!'"
    puts "Separate each with a semicolon"
    corrections = $stdin.gets.chomp.split(';')
    corrections.each do |correction|
      if correction.include?('->')
        data = correction.scan(/(.+) -> (.+)/)
        images[images.index(data[0])] = data[1]
      elsif correction.start_with?('+') && correction.end_with?('+')
        images << correction.tr('+', '')
      elsif correction.start_with?('!') && correction.end_with?('!')
        images.delete(correction.tr('!', ''))
      else
        puts "Bad format for correction '#{correction}', skipping"
      end
    end
    
    puts "Okay, let's try again then."
    images = check_correct(images, mod_name)
  end
  images
end

images = check_correct(images, mod_name)

puts images
