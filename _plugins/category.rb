module Jekyll

	class CategoryPage < Page
		def initialize(site, base, dir, category)
			@site = site
			@base = base
			@dir = dir
			@category = category
			@name = "index.html"

			self.process(@name)
			self.read_yaml(File.join(base, '_layouts'), 'category.html')
			self.data['category'] = category

			category_title_prefix = site.config['category_title_prefix'] || 'category: '
			self.data['title'] = "#{category_title_prefix}#{category}"
		end
	end

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

	class CategoryPageGenerator < Generator
		safe true

		def generate(site)
			if site.layouts.key? 'category'
				dir = site.config['category_dir'] || 'categories'
				site.categories.keys.each do |category|
					site.pages << CategoryPage.new(site, site.source, File.join(dir, category), category)
				end
			end
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
			end
		end
	end

end