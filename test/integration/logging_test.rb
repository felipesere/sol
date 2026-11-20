require "test_helper"

class LoggingTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as "Anna"
    @mira = children(:mira)
    @para = medicines(:paracetamol)
  end

  test "giving a dose records who gave it and when" do
    assert_difference "Dose.count", 1 do
      post child_doses_path(@mira), params: { dose: { medicine_id: @para.id, amount: 5, given_at: "2026-11-14T20:15", notes: "with yoghurt" } }
    end

    dose = Dose.last
    assert_redirected_to child_path(@mira)
    assert_equal "Anna", dose.user.name
    assert_equal Time.zone.local(2026, 11, 14, 20, 15), dose.given_at
    assert_equal "with yoghurt", dose.notes
  end

  test "a dose form for a blocked medicine warns but still allows recording" do
    Dose.create!(child: @mira, medicine: @para, user: users(:felipe), given_at: 30.minutes.ago, amount: 5)

    get new_child_dose_path(@mira, medicine_id: @para.id)

    assert_select ".flash", text: /next dose is allowed at/i
    assert_select "input[type=submit][value='Record anyway']"
  end

  test "a dose form for a ready medicine has no warning" do
    get new_child_dose_path(@mira, medicine_id: @para.id)

    assert_select ".flash", count: 0
    assert_select "input[type=submit][value='Give dose']"
  end

  test "doses can only use the child's own medicines" do
    assert_no_difference "Dose.count" do
      post child_doses_path(@mira), params: { dose: { medicine_id: medicines(:theos_paracetamol).id, amount: 3, given_at: "2026-11-14T20:15" } }
    end
  end

  test "editing and deleting a dose" do
    dose = Dose.create!(child: @mira, medicine: @para, user: users(:felipe), given_at: 1.hour.ago, amount: 5)

    patch child_dose_path(@mira, dose), params: { dose: { amount: 4, given_at: "2026-11-14T20:15", notes: "less" } }
    assert_equal 4, dose.reload.amount
    assert_equal "Felipe", dose.user.name # attribution stays with the original person

    assert_difference "Dose.count", -1 do
      delete child_dose_path(@mira, dose)
    end
  end

  test "logging a temperature" do
    assert_difference "Temperature.count", 1 do
      post child_temperatures_path(@mira), params: { temperature: { celsius: "38.4", measured_at: "2026-11-14T21:00", notes: "ear" } }
    end

    assert_equal 38.4, Temperature.last.celsius
    assert_equal "Anna", Temperature.last.user.name
  end

  test "an impossible temperature is rejected with a message" do
    assert_no_difference "Temperature.count" do
      post child_temperatures_path(@mira), params: { temperature: { celsius: "3.8", measured_at: "2026-11-14T21:00" } }
    end

    assert_response :unprocessable_entity
    assert_select ".flash", text: /Celsius/
  end

  test "editing and deleting a temperature" do
    reading = Temperature.create!(child: @mira, user: users(:felipe), measured_at: 1.hour.ago, celsius: 38.0)

    patch child_temperature_path(@mira, reading), params: { temperature: { celsius: "38.6", measured_at: "2026-11-14T20:00" } }
    assert_equal 38.6, reading.reload.celsius

    assert_difference "Temperature.count", -1 do
      delete child_temperature_path(@mira, reading)
    end
  end

  test "adding a child and a medicine" do
    post children_path, params: { child: { name: "Juno" } }
    juno = Child.find_by!(name: "Juno")
    assert_redirected_to child_medicines_path(juno)

    post child_medicines_path(juno), params: { medicine: { name: "Ibuprofen", dose_amount: 4, dose_unit: "ml", min_interval_minutes: 360, max_doses_per_24h: 3, active: "1" } }
    assert_equal 1, juno.medicines.count
  end

  test "adding a scheduled medicine shows progress for today on the dashboard" do
    post child_medicines_path(@mira), params: { medicine: { name: "Spray", kind: "scheduled", dose_amount: 1, dose_unit: "drop", min_interval_minutes: 240, doses_per_day: 3, course_days: 7, active: "1" } }
    spray = @mira.medicines.find_by!(name: "Spray")
    assert spray.scheduled?
    assert_equal Time.zone.today, spray.started_on

    get child_path(@mira)
    assert_match "0 of 3", response.body
    assert_match "day 1 of 7", response.body

    Dose.create!(child: @mira, medicine: spray, user: users(:felipe), given_at: Time.current, amount: 1)
    get child_path(@mira)
    assert_match "1 of 3", response.body
  end

  test "archived medicines disappear from the dashboard but keep their doses" do
    Dose.create!(child: @mira, medicine: @para, user: users(:felipe), given_at: 1.hour.ago, amount: 5)
    patch child_medicine_path(@mira, @para), params: { medicine: { active: "0" } }

    get child_path(@mira)

    assert_select "article", text: /Paracetamol/, count: 0
    assert_equal 1, @para.doses.count
  end
end
