module Aka
  class Links
    def initialize(links)
      @links = links.dup
    end

    def add(link)
      link = Configuration::Link.parse(link)
      @links << link unless @links.include?(link)
    end

    def delete(link)
      link = Configuration::Link.parse(link)
      @links.delete(link)
    end

    def any?
      @links.any?
    end

    def all
      @links.dup
    end

    def each(&blk)
      @links.each(&blk)
    end
  end
end
