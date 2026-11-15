require "test_helper"

class DashboardTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as "Anna"
    @mira = children(:mira)
    @para = medicines(:paracetamol)
  end

  def give(minutes_ago, medicine: @para, by: users(:felipe))
    Dose.create!(child: @mira, medicine: medicine, user: by, given_at: minutes_ago.minutes.ago, amount: medicine.dose_amount)
  end

  def take(celsius, minutes_ago, by: users(:felipe))
    Temperature.create!(child: @mira, user: by, measured_at: minutes_ago.minutes.ago, celsius: celsius)
  end

  test "root goes to the first child, or to the add-child form when there are none" do
    get root_path
    assert_redirected_to child_path(Child.order(:id).first)

    Child.destroy_all
    get root_path
    assert_redirected_to new_child_path
  end

  test "shows the latest temperature with who took it" do
    take(37.6, 60, by: users(:anna))

    get child_path(@mira)

    assert_select "section h1", "Mira"
    assert_select "section", text: /37\.6/
    assert_select "section", text: /Anna/
  end

  test "shows the peak of the last 24 hours" do
    take(39.2, 300); take(38.1, 100); take(40.0, 2000)

    get child_path(@mira)

    assert_select "section", text: /Peak, last 24 h\s+39\.2/
  end

  test "a medicine ready to give offers a primary action" do
    get child_path(@mira)

    assert_select "article", text: /Paracetamol/ do
      assert_select ".pill.good", "Ready"
      assert_select "a", text: /Give 5 ml/
    end
  end

  test "a medicine inside its interval shows when the next dose is allowed" do
    give(150)

    get child_path(@mira)

    assert_select "article", text: /Paracetamol/ do
      assert_select ".pill.warn", "Wait"
      assert_select "strong", clock_text(150.minutes.ago + 240.minutes)
      assert_select "a", text: "Give anyway"
    end
  end

  test "a medicine at its limit says so" do
    give(1300); give(900); give(500); give(300)

    get child_path(@mira)

    assert_select ".pill.crit", "Limit reached"
  end

  test "timeline is split into the last 24 hours and the 24 to 48 hours before" do
    give(60); give(1800); give(3000)

    get child_path(@mira)

    assert_select "div.label", text: "Last 24 hours"
    assert_select "div.label", text: "24 to 48 hours ago"
    assert_select "a[href*='/doses/'][href$='/edit']", count: 2 # the 3000 minute old dose is outside 48 hours
  end

  test "the chart defaults to 24 hours and the range links switch it" do
    get child_path(@mira)
    assert_select "[data-chart-data-value*='\"hours\":24']"
    assert_select ".seg a[aria-current=true]", text: "24 h"

    get child_path(@mira, range: 48)
    assert_select "[data-chart-data-value*='\"hours\":48']"
    assert_select ".seg a[aria-current=true]", text: "48 h"
  end

  test "people are shown by first name everywhere" do
    smith = User.create!(name: "Anna Smith")
    take(37.6, 60, by: smith)
    give(30, by: smith)

    get child_path(@mira)

    assert_select "a, p, span", text: /Smith/, count: 0
    assert_select "section", text: /Anna/
    assert_select "article", text: /by Anna/
    assert_select "a[href$='/edit']", text: /Anna/
    assert_select "[data-chart-data-value*='Smith']", count: 0
  end

  test "requires login" do
    delete session_path
    get child_path(@mira)
    assert_redirected_to login_path
  end

  private

  def clock_text(time)
    time.in_time_zone.strftime("%H:%M")
  end
end
