# Example data for local development: `bin/rails db:seed`.
# Never runs in production.
return if Rails.env.production?

anna = User.household("Anna")
felipe = User.household("Felipe")

mira = Child.find_or_create_by!(name: "Mira") { |c| c.birth_date = Date.new(2023, 3, 2) }
paracetamol = mira.medicines.find_or_create_by!(name: "Paracetamol") { |m| m.assign_attributes(dose_amount: 5, dose_unit: "ml", min_interval_minutes: 240, max_doses_per_24h: 4) }
ibuprofen = mira.medicines.find_or_create_by!(name: "Ibuprofen") { |m| m.assign_attributes(dose_amount: 4, dose_unit: "ml", min_interval_minutes: 360, max_doses_per_24h: 3) }

if mira.doses.none?
  now = Time.current
  [[2300, ibuprofen, felipe], [1900, paracetamol, anna], [1380, ibuprofen, anna], [1100, paracetamol, felipe],
   [760, ibuprofen, felipe], [640, paracetamol, anna], [150, paracetamol, felipe]].each do |ago, medicine, user|
    mira.doses.create!(medicine: medicine, user: user, given_at: now - ago.minutes, amount: medicine.dose_amount)
  end

  [[2820, 37.6, anna], [2520, 38.2, felipe], [2160, 38.8, anna], [1900, 39.0, felipe], [1700, 38.3, anna],
   [1400, 39.1, felipe], [1120, 39.2, anna], [900, 38.4, felipe], [770, 38.9, anna], [600, 38.1, felipe],
   [480, 38.4, anna], [330, 38.0, felipe], [210, 37.8, anna], [160, 38.3, felipe], [60, 37.6, anna]].each do |ago, celsius, user|
    mira.temperatures.create!(user: user, measured_at: now - ago.minutes, celsius: celsius)
  end
end
