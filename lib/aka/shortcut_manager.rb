module Aka
  class ShortcutManager
    def initialize(shortcuts)
      @shortcuts = shortcuts
    end

    def add(shortcut)
      @shortcuts << shortcut
    end

    def remove(shortcut)
      @shortcuts.delete_if do |item|
        item == shortcut
      end
    end

    def find(options)
      if options[:tag]
        @shortcuts.select do |shortcut|
          next unless shortcut.shortcut == options[:shortcut]

          options[:tag].find do |tag|
            shortcut.tag && shortcut.tag.include?(tag)
          end
        end
      else
        @shortcuts.select do |shortcut|
          shortcut.shortcut == options[:shortcut]
        end
      end
    end

    def generate(options)
      scripts = []
      functions = []

      excluded = match_by_tag(options[:tag] || []) do |tag, rows|
        rows.each do |row|
          unless row.function
            scripts << Shortcut.generate_output(row)
          else
            functions << Shortcut.generate_output(row)
          end
        end
      end

      if options[:output]
        File.open(File.expand_path(options[:output]), 'w+') do |f|
          scripts.each do |script|
            f.puts script
          end

          functions.each do |function|
            f.puts function
          end
        end

        puts "Generated #{options[:output]}."
      else
        scripts.each do |script|
          puts script
        end

        functions.each do |function|
          puts function
        end
      end

      excluded
    end

    def match_by_tag(tags, &blk)
      excluded = { :tags => [], :shortcuts => 0 }

      by_tag.each do |tag, rows|
        next if rows.empty?
        unless tag == :default || tags.empty? || tags.include?(tag)
          excluded[:tags] << tag
          excluded[:shortcuts] += rows.length
          next
        end

        yield(tag, rows)
      end

      excluded
    end

    def by_tag
      @shortcuts.inject({ :default => [] }) do |acc, row|
        if row.tag && !row.tag.empty?
          row.tag.each do |tag|
            acc[tag] ||= []
            acc[tag] << row
          end
        else
          acc[:default] << row
        end
        acc
      end
    end
  end
end
