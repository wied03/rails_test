module Screenshots
  def embed_screenshot(id)
    `screencapture -t png #{id}.png`
    embed("#{id}.png", "image/png")
  end
end

World(Screenshots)

After do
  # TODO: Only call this if we failed and if we're running in a certain output mode
  #embed_screenshot("screenshot-#{Time.new.to_i}")
end