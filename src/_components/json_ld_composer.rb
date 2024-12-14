class JsonLdComposer
  def initialize(metadata:, resources:)
    @metadata = metadata
    @resources = ResourceIndex.new(resources)
  end

  def to_json
    movie_theater.to_json
  end

  def movie_theater
    {
      "@context": "https://schema.org",
      "@type": "MovieTheater",
      "name": @metadata.title,
      "url": @metadata.website,
      "address": address,
      "telephone": @metadata.phone,
      "event": event,
    }
  end

  def address
    {
      "@type": "PostalAddress",
      "streetAddress": @metadata.street_address,
      "addressLocality": @metadata.city,
      "addressRegion": @metadata.province,
      "postalCode": @metadata.postal_code,
      "addressCountry": @metadata.country,
    }
  end

  def screening_event(resource, day, time)
    {
      "@type": "ScreeningEvent",
      "name": resource.data.titolo,
      "description": resource.data.descrizione,
      "startDate": "#{day}T#{time}+01:00",
      "location": {
        "@type": "MovieTheater",
        "name": @metadata.title,
        "url": @metadata.website,
        "address": address,
        "telephone": @metadata.phone,
      },
      "workPresented": {
        "@type": "Movie",
        "name": resource.data.titolo,
        "description": resource.data.descrizione,
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

  def theater_event(resource)
    {
      "@type": "TheaterEvent",
      "name": resource.data.titolo,
      "image": resource.data.img,
      "description": resource.data.descrizione,
      "startDate": "#{Date.parse(resource.data.dal)}T#{resource.data.orari.first}+01:00",
      "endDate": "#{Date.parse(resource.data.dal)}T23:00+01:00",
      "location": {
        "@type": "MovieTheater",
        "name": @metadata.title,
        "url": @metadata.website,
        "address": address,
        "telephone": @metadata.phone,
      },
      "workPresented": {
        "@type": "TheaterPlay",
        "name": resource.data.titolo,
        "image": resource.data.img,
        "description": resource.data.descrizione,
      },
      "offers": {
        "@type": "Offer",
        "price": "#{resource.data.prezzo || 20}.00",
        "priceCurrency": "EUR",
        "availability": "https://schema.org/InStock",
        "url": resource.data.ticket_url,
      }
    }
  end

  def event
    @resources.listed.each_with_object([]) do |resource, events|
      if resource.data.dal != resource.data.al
        (Date.today..Date.parse(resource.data.al)).each do |day|
          resource.data.orari.each do |time|
            events << screening_event(resource, day, time)
          end
        end
      else
        events << theater_event(resource)
      end
    end
  end
end
