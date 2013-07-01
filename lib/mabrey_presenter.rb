class MabreyPresenter < Struct.new(:first_name)
  def self.each(mabreys)
    mabreys.each { |mabrey| yield new mabrey }
  end

  def last_name
    'mabrey'
  end

  def full_name
    "#{first_name} #{last_name}".gsub(/\w+/, &:capitalize)
  end

  def email
    "#{first_name}@#{last_name}s.com"
  end

  def gravatar(size=390)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email)}.jpg?s=#{size}"
  end

  def twitter_handel
    "@#{twitter_username}"
  end

  def twitter_profile
    "http://twitter.com/#{twitter_username}"
  end


  private


  def twitter_username
    "#{first_name}#{last_name}"
  end
end
