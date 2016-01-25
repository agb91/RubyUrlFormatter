require 'normalize_url'
require 'rubygems'
require 'httpclient'
require 'net/http'
require 'uri'


def printer(text, value)
  puts text + ":  " + value.to_s
end

def addSlash(u)
  u = u.to_s + "/"
  u = URI.parse(u)
  u
end

def getPathFrom(u)
  begin
    req = Net::HTTP::Get.new(u.path, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
  rescue ArgumentError
    puts "argument error, I'll add the final slash"
    u = addSlash(u)
    req = Net::HTTP::Get.new(u.path, { 'User-Agent' => 'Mozilla/5.0 (etc...)' })
  end
  req
end

def getResponse(u)
  begin
    response = Net::HTTP.get_response(URI(u))
    if response.code.to_s=="404"
      puts "404 error"
      exit
    end
  rescue SocketError
    puts "I believe it's not a real url"
    exit
  end
  response
end

#redirect
def tryToFollow(uri_str, limit = 10, verbose)
  # You should choose a better exception.
  returned = ""
  returned = uri_str.to_s
  #puts "uri string in time to follow: " + returned
  raise ArgumentError, 'too many HTTP redirects' if limit == 0

  response = getResponse(uri_str)

  case response
  when Net::HTTPSuccess then
    #puts response.code
  when Net::HTTPRedirection then
    location = response['location']
    returned = location
    #warn "redirected to #{location}"
    tryToFollow(location, limit - 1)
  else
    response.value
  end
  returned
end

def addHTTP (input)
  start = input[0..4]
  starts = input[0..3]
  if (!start.casecmp("https").zero? && !starts.casecmp("http").zero?)
     input = "http://"+input
  end
  input
end

#remove the s in https
def removeSinHttp(i, verbose)
  if(verbose==1)
    puts "prima di reg exp:  " + i.to_s
  end
  if i.match(/^https/)
    i = "http" + i[5..-1]
  end
  if (verbose==1)
    puts "dopo reg exp:  " + i.to_s
  end
  i
end

#basic normalization of url
def norm(i)
  NormalizeUrl.process(i)
  i
end

def normalizetor(input, verbose)
   #eventually add http:// if there isn't
  ris = addHTTP(input)

  ris = tryToFollow(ris, 10, 0)

  ris = norm(ris)

  ris = removeSinHttp(ris,0)

  ris
end




#inp = "http://blog.kischuk.com/2008/06/23/create-tinyurl-like-urls-in-ruby/"
inp = "http://tinyurl.com/hdzfyrq"
#inp = "google.it"
#inp = "https://www.glassdoor.com/index.htm"
#inp = "gatto"
#inp = "http://www.wired.it/internet/web/2015/05/05/15-pagine-errore-404/vcd"

printer("INIZIALE", inp)
r = normalizetor(inp, 0)
printer("FINALE", r)



