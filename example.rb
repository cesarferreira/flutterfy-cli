
def detect_pattern(input, target)
  pattern = /ff (\w+) --open #{Regexp.escape(target)}/
  match = pattern.match(input)

  if match
    trainer = match[1]
    return trainer, true
  else
    return nil, false
  end
end

trainer, pattern_found = detect_pattern("ff trainerx --open swagger", "swagger")

if pattern_found
  puts "Pattern detected. Trainer: #{trainer}"
else
  puts "Pattern not detected."
end
