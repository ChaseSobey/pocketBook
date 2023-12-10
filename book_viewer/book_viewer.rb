require "sinatra"
require "sinatra/reloader"
require 'tilt/erubis'

before do
  @contents = File.readlines('data/toc.txt')
end

helpers do
  def in_paragraphs(text)
    text.split("\n\n").each_with_index do |line, index|
      "<p id=paragraph#{index}>#{line}</p>"
    end.join
  end
  
  def each_chapter
    @contents.each_with_index do |title, index|
      number = index + 1
      contents = File.read("data/chp#{index + 1}.txt")
      yield(number, title, contents)
    end
  end
    
    def highlight(text, term)
      text.gsub(term, %(<strong>#{term}</strong>))
    end
  
  def chapter_matches(query)
    results = []
    
    return results if !query
    each_chapter do |number, title, contents|
      matches = {}
      contents.split("\n\n").each_with_index do |paragraph, index|
        matches[index] = paragraph if paragraph.include?(query)
      end
       results << {number: number, title: title, paragraphs: matches} if matches.any?
    end
    results
  end
    
end

not_found do
  redirect '/'
end

get "/" do
  @title = 'The Adventures of Sherlock Holmes'
  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i
  
  @chapter = File.read("data/chp#{number}.txt")
  @title = "Chapter #{number}: #{@contents[number - 1]}"
  
  erb :chapter, layout: :layout
end

get "/search" do
  @title = "Search"
  @results = chapter_matches(params[:query])
  erb :search
end

