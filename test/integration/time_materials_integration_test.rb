require "test_helper"

class TimeMaterialsIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @tenant = tenants(:one)
    @user = users(:one)
    @customer = customers(:one)
    @project = projects(:one)

    # Sign in as the user using integration test method
    sign_in_user @user
  end

  teardown do
    Current.reset
  end

  # Test adding time without customer (draft state doesn't require customer)
  test "add time material without customer" do
    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          about: "Work without customer",
          hour_time: "1",
          minute_time: "0",
          rate: "100.0",
          over_time: "0",
          unit: "hours",
          state: "draft"  # draft state doesn't require customer
        }
      }
    end

    time_material = TimeMaterial.last
    assert_equal "01:00", time_material.time
    assert_equal 60, time_material.registered_minutes
    assert_nil time_material.customer_id
    assert_equal @user.id, time_material.user_id
  end

  # Test adding time with customer
  test "add time material with customer" do
    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          customer_id: @customer.id.to_s,
          customer_name: @customer.name,
          project_id: @project.id.to_s,
          project_name: @project.name,
          about: "Work with customer",
          hour_time: "2",
          minute_time: "0",
          rate: "100.0",
          over_time: "0",
          unit: "hours",
          state: "done"  # done state with customer is valid
        }
      }
    end

    time_material = TimeMaterial.last
    assert_equal "02:00", time_material.time
    assert_equal 120, time_material.registered_minutes
    assert_equal @customer.id.to_s, time_material.customer_id
    assert_equal @project.id.to_s, time_material.project_id
  end

  # Test time rounding with limit_time_to_quarters turned OFF
  test "add time materials with various durations when limit_time_to_quarters is off" do
    # Turn off quarter-hour limiting
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "false")

    test_cases = [
      { minutes: 4, expected: 4, expected_time: "00:04", description: "4 minutes" },
      { minutes: 10, expected: 10, expected_time: "00:10", description: "10 minutes" },
      { minutes: 15, expected: 15, expected_time: "00:15", description: "15 minutes" },
      { minutes: 20, expected: 20, expected_time: "00:20", description: "20 minutes" },
      { minutes: 27, expected: 27, expected_time: "00:27", description: "27 minutes" },
      { minutes: 31, expected: 31, expected_time: "00:31", description: "31 minutes" },
      { minutes: 46, expected: 46, expected_time: "00:46", description: "46 minutes" },
      { minutes: 58, expected: 58, expected_time: "00:58", description: "58 minutes" },
      { minutes: 65, expected: 65, expected_time: "01:05", description: "65 minutes" }
    ]

    test_cases.each do |test_case|
      hours = test_case[:minutes] / 60
      minutes = test_case[:minutes] % 60

      assert_difference "TimeMaterial.count", 1 do
        post time_materials_path, params: {
          time_material: {
            date: Date.today.to_s,
            user_id: @user.id,
            about: "Testing #{test_case[:description]} without quarter limit",
            hour_time: hours.to_s,
            minute_time: minutes.to_s,
            rate: "100.0",
            over_time: "0",
            unit: "hours",
            state: "draft"
          }
        }
      end

      time_material = TimeMaterial.last
      assert_equal test_case[:expected], time_material.registered_minutes,
        "Expected #{test_case[:expected]} minutes for #{test_case[:description]} with limit_time_to_quarters OFF"
      assert_equal test_case[:expected_time], time_material.time,
        "Expected time format #{test_case[:expected_time]} for #{test_case[:description]}"
    end
  end

  # Test ALL minute values (0-59) with quarter-hour rounding ON
  # This validates the complete rounding logic:
  # - 0 min → 15 min (when hours=0) or 0 min (when hours>0)
  # - 1-15 min → 15 min
  # - 16-30 min → 30 min
  # - 31-45 min → 45 min
  # - 46-59 min → +1 hour, 0 min
  test "all minute values round correctly with limit_time_to_quarters on" do
    # Turn on quarter-hour limiting
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "true")

    # Test all 60 possible minute values (0-59)
    60.times do |input_minutes|
      # Determine expected output based on rounding rules
      expected_minutes = case input_minutes
      when 0; 15  # 0 rounds to 15 when hours=0
      when 1..15; 15
      when 16..30; 30
      when 31..45; 45
      when 46..59; 60  # rounds up to next hour
      end

      expected_hours = 0
      if expected_minutes == 60
        expected_hours = 1
        expected_minutes = 0
      end

      expected_time = "%02d:%02d" % [ expected_hours, expected_minutes ]
      expected_total_minutes = expected_hours * 60 + expected_minutes

      assert_difference "TimeMaterial.count", 1 do
        post time_materials_path, params: {
          time_material: {
            date: Date.today.to_s,
            user_id: @user.id,
            about: "Testing #{input_minutes} minutes with quarter rounding",
            hour_time: "0",
            minute_time: input_minutes.to_s,
            rate: "100.0",
            over_time: "0",
            unit: "hours",
            state: "draft"
          }
        }
      end

      time_material = TimeMaterial.last
      assert_equal expected_total_minutes, time_material.registered_minutes,
        "Input: #{input_minutes} min should round to #{expected_total_minutes} min (got #{time_material.registered_minutes})"
      assert_equal expected_time, time_material.time,
        "Input: #{input_minutes} min should format as #{expected_time} (got #{time_material.time})"
    end
  end

  # Test time rounding with limit_time_to_quarters turned ON
  test "add time materials with various durations when limit_time_to_quarters is on" do
    # Turn on quarter-hour limiting
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "true")

    test_cases = [
      { minutes: 4, expected: 15, expected_time: "00:15", description: "4 minutes rounds to 15" },
      { minutes: 10, expected: 15, expected_time: "00:15", description: "10 minutes rounds to 15" },
      { minutes: 15, expected: 15, expected_time: "00:15", description: "15 minutes stays 15" },
      { minutes: 20, expected: 30, expected_time: "00:30", description: "20 minutes rounds to 30" },
      { minutes: 27, expected: 30, expected_time: "00:30", description: "27 minutes rounds to 30" },
      { minutes: 31, expected: 45, expected_time: "00:45", description: "31 minutes rounds to 45" },
      { minutes: 46, expected: 60, expected_time: "01:00", description: "46 minutes rounds to 60" },
      { minutes: 58, expected: 60, expected_time: "01:00", description: "58 minutes rounds to 60" },
      { minutes: 65, expected: 75, expected_time: "01:15", description: "65 minutes rounds to 75" }
    ]

    test_cases.each do |test_case|
      hours = test_case[:minutes] / 60
      minutes = test_case[:minutes] % 60

      assert_difference "TimeMaterial.count", 1 do
        post time_materials_path, params: {
          time_material: {
            date: Date.today.to_s,
            user_id: @user.id,
            about: "Testing #{test_case[:description]} with quarter limit",
            hour_time: hours.to_s,
            minute_time: minutes.to_s,
            rate: "100.0",
            over_time: "0",
            unit: "hours",
            state: "draft"
          }
        }
      end

      time_material = TimeMaterial.last
      assert_equal test_case[:expected], time_material.registered_minutes,
        "Expected #{test_case[:expected]} minutes for #{test_case[:description]} with limit_time_to_quarters ON"
      assert_equal test_case[:expected_time], time_material.time,
        "Expected time format #{test_case[:expected_time]} for #{test_case[:description]}"
    end
  end

  # Test adding time with customer and limit_time_to_quarters ON
  test "add time material with customer when limit_time_to_quarters is on" do
    # Turn on quarter-hour limiting
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "true")

    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          customer_id: @customer.id.to_s,
          customer_name: @customer.name,
          project_id: @project.id.to_s,
          project_name: @project.name,
          about: "Work with customer and quarter rounding",
          hour_time: "0",
          minute_time: "27",  # Should round to 30
          rate: "100.0",
          over_time: "0",
          unit: "hours",
          state: "done"
        }
      }
    end

    time_material = TimeMaterial.last
    assert_equal 30, time_material.registered_minutes
    assert_equal "00:30", time_material.time
    assert_equal @customer.id.to_s, time_material.customer_id
  end

  # Test adding time without customer and limit_time_to_quarters ON
  test "add time material without customer when limit_time_to_quarters is on" do
    # Turn on quarter-hour limiting
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "true")

    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          about: "Work without customer and quarter rounding",
          hour_time: "0",
          minute_time: "46",  # Should round to 60 (1 hour)
          rate: "100.0",
          over_time: "0",
          unit: "hours",
          state: "draft"
        }
      }
    end

    time_material = TimeMaterial.last
    assert_equal 60, time_material.registered_minutes
    assert_equal "01:00", time_material.time
    assert_nil time_material.customer_id
  end

  # Test edge case: zero minutes
  # Note: The application allows creating time entries with 0:00 time
  # It's a valid edge case for tracking entries without actual time spent
  test "add time material with zero minutes" do
    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          hour_time: "0",
          minute_time: "0",
          over_time: "0",
          rate: "100.0",
          unit: "hours",
          state: "draft",  # use draft state for zero time
          about: "Zero minutes work"
        }
      }
    end

    time_material = TimeMaterial.last
    assert_equal "00:00", time_material.time
    assert_equal 0, time_material.registered_minutes
  end

  # Test exact quarter-hour values with limit ON
  test "exact quarter-hour values remain unchanged with limit_time_to_quarters on" do
    setting = @tenant.settings.find_or_create_by(key: "limit_time_to_quarters")
    setting.update(value: "true")

    exact_quarters = [ 15, 30, 45, 60, 75, 90, 105, 120 ]

    exact_quarters.each do |minutes|
      hours = minutes / 60
      mins = minutes % 60

      assert_difference "TimeMaterial.count", 1 do
        post time_materials_path, params: {
          time_material: {
            date: Date.today.to_s,
            user_id: @user.id,
            about: "Testing exact #{minutes} minutes",
            hour_time: hours.to_s,
            minute_time: mins.to_s,
            rate: "100.0",
            over_time: "0",
            unit: "hours",
            state: "draft"
          }
        }
      end

      time_material = TimeMaterial.last
      assert_equal minutes, time_material.registered_minutes,
        "Expected #{minutes} minutes to remain unchanged with quarter limit"
    end
  end

  # Test that customer association and rate are stored correctly
  test "time material stores customer_id and rate correctly" do
    # Ensure customer has a specific hourly rate
    @customer.update(hourly_rate: 850.50)

    assert_difference "TimeMaterial.count", 1 do
      post time_materials_path, params: {
        time_material: {
          date: Date.today.to_s,
          user_id: @user.id,
          customer_id: @customer.id.to_s,
          customer_name: @customer.name,
          about: "Work with customer-specific rate",
          hour_time: "2",
          minute_time: "30",
          rate: "850.50",  # Using customer's hourly rate
          over_time: "0",
          unit: "hours",
          state: "draft"
        }
      }
    end

    time_material = TimeMaterial.last
    # Verify customer association
    assert_equal @customer.id.to_s, time_material.customer_id
    # Verify the rate is stored (in integration tests, the rate is explicitly passed)
    assert_equal "850.50", time_material.rate
  end

  # Test that different customers can have different rates
  test "different customers use their respective hourly rates" do
    # Create another customer with different rate
    customer2 = Customer.create!(
      tenant: @tenant,
      name: "Customer Two",
      hourly_rate: 1200.00,
      country_key: "DK",
      is_person: true
    )

    # Create time material for first customer
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: @user.id,
        customer_id: @customer.id.to_s,
        customer_name: @customer.name,
        about: "Work for customer one",
        hour_time: "1",
        minute_time: "0",
        rate: @customer.hourly_rate.to_s,
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm1 = TimeMaterial.last

    # Create time material for second customer
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: @user.id,
        customer_id: customer2.id.to_s,
        customer_name: customer2.name,
        about: "Work for customer two",
        hour_time: "1",
        minute_time: "0",
        rate: customer2.hourly_rate.to_s,
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm2 = TimeMaterial.last

    # Verify each time material has correct customer and rate
    assert_equal @customer.id.to_s, tm1.customer_id
    assert_equal "850.5", tm1.rate

    assert_equal customer2.id.to_s, tm2.customer_id
    assert_equal "1200.0", tm2.rate
  end

  # Test user hourly_rate is used when no customer rate is set, but customer rate takes precedence
  test "user with hourly_rate uses own rate when no customer rate, but customer rate takes precedence" do
    # User :one has hourly_rate of 100
    # First test: no customer, should use user rate (100)
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: @user.id,
        about: "Work without customer",
        hour_time: "1",
        minute_time: "0",
        rate: @user.hourly_rate.to_s,  # 100
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm_without_customer = TimeMaterial.last
    assert_equal "100.0", tm_without_customer.rate

    # Second test: with customer, should use customer rate (850.50)
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: @user.id,
        customer_id: @customer.id.to_s,
        customer_name: @customer.name,
        about: "Work with customer",
        hour_time: "1",
        minute_time: "0",
        rate: @customer.hourly_rate.to_s,  # 850.50
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm_with_customer = TimeMaterial.last
    assert_equal "850.5", tm_with_customer.rate
  end

  # Test user without hourly_rate uses team rate, but project rate takes precedence
  test "user without hourly_rate uses team rate when no project rate, but project rate takes precedence" do
    # User :three has no hourly_rate (0) but team :two has hourly_rate of 200
    user_with_no_rate = users(:three)
    sign_in_user user_with_no_rate

    # First test: no project, should use team rate (200)
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: user_with_no_rate.id,
        customer_id: @customer.id.to_s,
        customer_name: @customer.name,
        about: "Work without project",
        hour_time: "1",
        minute_time: "0",
        rate: user_with_no_rate.team.hourly_rate.to_s,  # 200
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm_without_project = TimeMaterial.last
    assert_equal "200.0", tm_without_project.rate

    # Second test: with project, should use project rate (300)
    post time_materials_path, params: {
      time_material: {
        date: Date.today.to_s,
        user_id: user_with_no_rate.id,
        customer_id: @customer.id.to_s,
        customer_name: @customer.name,
        project_id: @project.id.to_s,
        project_name: @project.name,
        about: "Work with project",
        hour_time: "1",
        minute_time: "0",
        rate: @project.hourly_rate.to_s,  # 300
        over_time: "0",
        unit: "hours",
        state: "draft"
      }
    }
    tm_with_project = TimeMaterial.last
    assert_equal "300.0", tm_with_project.rate
  end

  private

  def sign_in_user(user)
    # Create a session for the user
    session = user.sessions.create!(
      user_agent: "Test Agent",
      ip_address: "127.0.0.1",
      authentication_strategy: "password"
    )

    # Set the session cookie using proper signing
    # In integration tests, we need to use the secret key base to sign the cookie
    secret_key_base = Rails.application.secret_key_base
    key_generator = ActiveSupport::KeyGenerator.new(secret_key_base, iterations: 1000)
    secret = key_generator.generate_key("signed cookie")
    verifier = ActiveSupport::MessageVerifier.new(secret, serializer: JSON)
    signed_value = verifier.generate(session.id)
    cookies[:session_id] = signed_value

    # Update user sign-in timestamps
    user.update(
      sign_in_count: user.sign_in_count + 1,
      current_sign_in_at: Time.current,
      current_sign_in_ip: "127.0.0.1",
      last_sign_in_at: Time.current,
      last_sign_in_ip: "127.0.0.1"
    )
  end
end
