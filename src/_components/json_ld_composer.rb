class JsonLdComposer
  def initialize(metadata:, resources:)
    @metadata = metadata
    @resources = resources
  end

  def movie_theater_json
    {
      "@context": "https://schema.org",
      "@type": "MovieTheater",
      "name": @metadata.title,
      "url": @metadata.website,
      "address": address_json,
      "telephone": @metadata.phone,
      "event": event_json
    }
  end

  def address_json
    {
      "@type": "PostalAddress",
      "streetAddress": @metadata.street_address,
      "addressLocality": @metadata.city,
      "addressRegion": @metadata.province,
      "postalCode": @metadata.postal_code,
      "addressCountry": @metadata.country,
    }
  end

  def screening_event_json(resource, day, time)
    {
      "@type": "ScreeningEvent",
      "name": resource.data.titolo,
      "startDate": "#{day}T#{time}+01:00",
      "workPresented": {
        "@type": "Movie",
        "name": resource.data.titolo,
        "image": resource.data.img,
      },
      "offers": {
        "@type": "Offer",
        "price": "7.00",
        "priceCurrency": "EUR",
        "availability": "https://schema.org/InStock",
      }
    }
  end

  def theater_event_json(resource)
    {
      "@type": "TheaterEvent",
      "name": resource.data.titolo,
      "image": resource.data.img,
      "startDate": "#{Date.parse(resource.data.dal)}T#{resource.data.orari.first}+01:00",
      "endDate": "#{Date.parse(resource.data.dal)}T23:00+01:00",
      "location": {
        "@type": "MovieTheater",
        "name": @metadata.title,
        "address": address_json,
      },
      "workPresented": {
        "@type": "TheaterPlay",
        "name": resource.data.titolo,
        "image": resource.data.img,
      }
    }
  end

  def event_json
    @resources.select { |resource| Date.parse(resource.data.al) >= Date.today }
              .sort { |a, b| DateTime.parse("#{a.data.dal}T#{a.data.orari.first}") <=> DateTime.parse("#{b.data.dal}T#{b.data.orari.first}") }
              .each_with_object([]) do |resource, events|
      if resource.data.dal != resource.data.al
        (Date.parse(resource.data.dal)..Date.parse(resource.data.al)).each do |day|
          next if day < Date.today
          
          resource.data.orari.each do |time|
            events << screening_event_json(resource, day, time)
          end
        end
      else
        events << theater_event_json(resource)
      end
    end
  end
end
