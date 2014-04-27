module Aka
  class Shortcuts
    def initialize(shortcuts)
      @shortcuts = shortcuts.dup
    end

    def append(shortcut)
      @shortcuts[count + 1] = shortcut
    end

    def replace(key, shortcut)
      @shortcuts[key] = shortcut
    end

    def delete(key)
      @shortcuts.delete(key)
    end

    def count
      result, _ = @shortcuts.max { |(n, _)| n }
      result || 0
    end

    def all
      @shortcuts.dup
    end

    def find(options)
      if options[:tag]
        @shortcuts.select do |_, row|
          next unless row.shortcut == options[:shortcut]

          options[:tag].find do |tag|
            row.tag && row.tag.include?(tag)
          end
        end
      else
        @shortcuts.select do |_, row|
          row.shortcut == options[:shortcut]
        end
      end
    end

    def generate(options)
      scripts = []
      functions = []

      excluded = match_by_tag(options[:tag] || []) do |tag, rows|
        rows.each do |row|
          unless row.function
            scripts << Configuration::Shortcut.generate_output(row)
          else
            functions << Configuration::Shortcut.generate_output(row)
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

    def excluded_output(excluded)
      return if excluded[:tags].empty?

      tags = excluded[:tags].map { |t| '#' + t }.join(', ')
      $stderr.puts "#{excluded[:shortcuts]} shortcut(s) excluded (#{tags})."
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
      @shortcuts.inject({ :default => [] }) do |acc, (_, row)|
        if row.tag
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
