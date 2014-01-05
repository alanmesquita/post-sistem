require "bundler/setup"
require "rubygems" if RUBY_VERSION < '1.9'
require "sinatra"
require "haml"
require "JSON"

require "./lib/Post"
require "./lib/Banword"

class App < Sinatra::Base

    get '/' do
        @page = params[:p] || 1
        @numPerPage = 2
        @posts = getPost.all('*', "LIMIT #{(@page.to_i-1)*@numPerPage},#{@numPerPage}")

        allPosts = getPost.all("COUNT(*) AS qnt")
        allPosts = allPosts.fetch_hash["qnt"].to_i
        @paginate = (allPosts.to_f/@numPerPage).ceil

        haml :index
    end

    post '/' do
        getPost.addPost(getBanWord.clean(params[:text]))
        @referer = request.referer

        haml :success
    end

    get '/post/:id' do
        @parentPostId = params[:id]
        @posts = getPost.getChildrensByRootId(params[:id])
        haml :posts
    end

    post '/post/add/:id' do
        post = Hash.new

        post["parent_id"] = params[:id]
        post["post_id"] = params["post_id"]
        post["reply"] = getBanWord.clean(params["reply"])

        begin
            getPost.addReply(post)
            @referer = request.referer

            haml :success
        rescue Exception=>e
            puts e
        end
    end

    private

    def getBanWord ()
        return Banword.new
    end

    def getPost ()
        return Post.new
    end

end

App.run!
