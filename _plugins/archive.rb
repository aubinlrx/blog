require 'json'

module Jekyll

	class Archive < Page
		def initialize(site, base, dir, period, posts)
			@site = site
			@base = base
			@dir = dir
			@period = period
			@posts = posts
			@name = "index.html"

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'archive.html')
			self.data['month'] = period['month']

			month_title_prefix = site.config['month_title_prefix'] || 'Month: '
			self.data['title'] = "#{month_title_prefix}#{period['month']}"
			self.data['posts_by_month'] = posts
		end
	end

	class ArchivePageGenerator < Generator
		safe true

		def generate(site)
			if site.layouts.key? 'archive'
				dir = site.config['archive_dir'] || 'archives'
				site.posts.group_by{ |c| {"month" => c.date.month, "year" => c.date.year} }.each do |period, posts|
					site.pages << Archive.new(site, site.source, File.join(dir, period['year'].to_s, period['month'].to_s), period, posts)
				end
				json_dir = site.config['json_dir'] || 'assets/json' 
				render_json(json_dir, site)
			end
		end

		def render_json(dir, site)
			path = dir + '/archive.json'

			list_of_month = Array.new

			site.posts.last(3).group_by{ |c| {"month" => c.date.month, "year" => c.date.year} }.each do |period, post|
				url = 'archives/archive.html#' + period['month'].to_s
				month = {:month => period['month'], :year => period['year'], :url => url}
				list_of_month << month
			end

			File.open(path, 'w') do |f|
				f.write(list_of_month.to_json)
			end
		end

	end

end