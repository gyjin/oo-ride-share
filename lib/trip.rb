require 'csv'
require_relative 'csv_record'

module RideShare
  class Trip < CsvRecord
    attr_reader :id, :passenger, :passenger_id, :start_time, 
    :end_time, :cost, :rating, :driver_id, :driver
    
    def initialize(id:,
      passenger: nil, passenger_id: nil,
      start_time:, end_time:, cost: nil, rating:,
      driver_id: nil, driver: nil)
      super(id)
      
      if passenger
        @passenger = passenger
        @passenger_id = passenger.id
      elsif passenger_id
        @passenger_id = passenger_id
      else
        raise ArgumentError, 'Passenger or passenger_id is required'
      end
      
      if end_time == nil
        @start_time = start_time
      elsif end_time < start_time
        raise ArgumentError.new('The end time cannot be before the start time')
      else
        @start_time = start_time
        @end_time = end_time
      end
      
      @cost = cost
      @rating = rating
      
      if @rating == nil
      elsif @rating > 5 || @rating < 1
        raise ArgumentError.new("Invalid rating #{@rating}")
      end
      
      if driver
        @driver = driver
        @driver_id = driver.id
      elsif driver_id
        @driver_id = driver_id
      else
        raise ArgumentError, 'Driver or driver_id is required'
      end
    end
    
    def inspect
      # Prevent infinite loop when puts-ing a Trip
      # trip contains a passenger contains a trip contains a passenger...
      "#<#{self.class.name}:0x#{self.object_id.to_s(16)} " +
      "ID=#{id.inspect} " +
      "PassengerID=#{passenger&.id.inspect}>"
    end
    
    def connect(passenger)
      @passenger = passenger
      passenger.add_trip(self)
    end
    
    def connect_drivers(driver)
      @driver = driver
      driver.add_trip(self)
    end
    
    def duration
      if end_time == nil
        return 0
      else
        return end_time - start_time
      end
    end
    
    private
    
    def self.from_csv(record)
      return self.new(
        id: record[:id],
        passenger_id: record[:passenger_id],
        start_time: Time.parse(record[:start_time]),
        end_time: Time.parse(record[:end_time]),
        cost: record[:cost],
        rating: record[:rating],
        driver_id: record[:driver_id]
      )
    end
  end
end
