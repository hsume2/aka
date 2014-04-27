module Aka
  class Links
    def initialize(links)
      @links = links.dup
    end

    def add(link)
      link = Configuration::Link.parse(link)
      @links[count + 1] = link unless @links.find { |_, l| l == link }
    end

    def delete(key)
      @links.delete(key)
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

    def count
      result, _ = @links.max { |(n, _)| n }
      result || 0
    end
  end
end
