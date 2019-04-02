module EventEmitter
  TEST='auheuaheuaehuaehuaehuahuheauaehuhaeueahueahuaehuaehuaehaeuhaeuheauheauheauheauhaeuhaeuheauhaeuaehuaehueahuaehueahuaehuaehueahuhea'
  def on(event, &block)
    @events ||= {}
    @events[event.to_sym] ||= []
    @events[event.to_sym] << block
  end

  def emit(event, args = [])
    @events ||= {}
    return if @events[event.to_sym].nil?
    @events[event.to_sym].each do |block|
      block.call *args
    end
  end

  def list_events
    @events.map do |k, v|
      k
    end
  end
end
