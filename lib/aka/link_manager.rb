module Aka
  class LinkManager
    def initialize(links)
      @links = links
    end

    def find(link)
      @links.find do |item|
        item == link
      end
    end

    def add(new_link)
      return if found = find(new_link)
      @links << new_link
    end

    def remove(key)
      @links.delete_at(key.to_i - 1)
    end

    def any?(&block)
      @links.any?(&block)
    end

    def each(&block)
      @links.each(&block)
    end
  end
end
