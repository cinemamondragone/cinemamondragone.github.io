class ResourceIndex
  def initialize(resources)
    @resources = resources
  end

  def listed
    @resources.select { |resource| Date.parse(resource.data.al) >= Date.today }
              .sort { |a, b| parse_time(a) <=> parse_time(b) }
  end

  private

  def parse_time(resource)
    DateTime.parse("#{resource.data.dal}T#{resource.data.orari.first}")
  end
end