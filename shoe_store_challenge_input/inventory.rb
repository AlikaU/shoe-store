#!/usr/bin/ruby

require 'json'

STDOUT.sync = true

STORE_STORES = [ 'ALDO Centre Eaton', 'ALDO Destiny USA Mall', 'ALDO Pheasant Lane Mall', 'ALDO Holyoke Mall', 'ALDO Maine Mall', 'ALDO Crossgates Mall', 'ALDO Burlington Mall', 'ALDO Solomon Pond Mall', 'ALDO Auburn Mall', 'ALDO Waterloo Premium Outlets' ]
SHOES_MODELS = [ 'ADERI', 'MIRIRA', 'CAELAN', 'BUTAUD', 'SCHOOLER', 'SODANO', 'MCTYRE', 'CADAUDIA', 'RASIEN', 'WUMA', 'GRELIDIEN', 'CADEVEN', 'SEVIDE', 'ELOILLAN', 'BEODA', 'VENDOGNUS', 'ABOEN', 'ALALIWEN', 'GREG', 'BOZZA' ]
INVENTORY = Array(0..100)
RANDOMNESS = Array(1..3)

mean = SHOES_MODELS.size / 2.0
stddev = SHOES_MODELS.size / 3.0


# from https://stackoverflow.com/questions/5825680/code-to-generate-gaussian-normally-distributed-random-numbers-in-ruby
def normal_distribution_index(mean, stddev, size)
  theta = 2 * Math::PI * rand
  rho = Math.sqrt(-2 * Math.log(1 - rand))
  scale = stddev * rho
  x = mean + scale * Math.cos(theta)
  x = x.round.clamp(0, size - 1)
end


loop do
  # Shuffle the shoe models array sometimes, to simulate different models becoming popular
  if rand < 0.05 # 5% chance to shuffle
    SHOES_MODELS.shuffle!
  end

  RANDOMNESS.sample.times do
    # Probability of selecting shoe models is normally distributed
    model_index = normal_distribution_index(mean, stddev, SHOES_MODELS.size)
    puts JSON.generate({
      store: STORE_STORES.sample,
      model: SHOES_MODELS[model_index],
      inventory: INVENTORY.sample
    }, quirks_mode: true)
  end
  sleep 1
end
