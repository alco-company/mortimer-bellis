class DashboardsController < MortimerController
  before_action :set_dashboard, only: %i[ show ]

  # before_action :set_dashboard, only: %i[ show edit update destroy ]

  # # GET /dashboards or /dashboards.json
  # def index
  #   @dashboards = Dashboard.all
  # end

  # # GET /dashboards/show_dashboard or /dashboards/show_dashboard.json
  def show_dashboard
    Current.tenant.check_tasks
    # @activity_list = Current.user.tenant.punches.order(punched_at: :desc).take(10)
    @tasks = Task.by_tenant.tasked_for_the(Current.user).uncompleted.order(due_at: :asc).take(10)
    @range_view = params[:range_view] || "week"
    @punch_clock = PunchClock.where(tenant: Current.user.tenant).first rescue nil
    @quote = quotes[:quotes][rand(0..49)]
  end

  # # GET /dashboards/new
  # def new
  #   @dashboard = Dashboard.new
  # end

  # # GET /dashboards/1/edit
  # def edit
  # end

  # # POST /dashboards or /dashboards.json
  # def create
  #   @dashboard = Dashboard.new(dashboard_params)

  #   respond_to do |format|
  #     if @dashboard.save
  #       format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully created." }
  #       format.json { render :show, status: :created, location: @dashboard }
  #     else
  #       format.html { render :new, status: :unprocessable_entity }
  #       format.json { render json: @dashboard.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # PATCH/PUT /dashboards/1 or /dashboards/1.json
  # def update
  #   respond_to do |format|
  #     if @dashboard.update(dashboard_params)
  #       format.html { redirect_to dashboard_url(@dashboard), notice: "Dashboard was successfully updated." }
  #       format.json { render :show, status: :ok, location: @dashboard }
  #     else
  #       format.html { render :edit, status: :unprocessable_entity }
  #       format.json { render json: @dashboard.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # # DELETE /dashboards/1 or /dashboards/1.json
  # def destroy
  #   @dashboard.destroy!

  #   respond_to do |format|
  #     format.html { redirect_to dashboards_url, notice: "Dashboard was successfully destroyed." }
  #     format.json { head :no_content }
  #   end
  # end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dashboard
      @dashboard = Dashboard.find_by(tenant: Current.tenant)
      unless @dashboard
        @dashboard = Dashboard.create(tenant: Current.tenant, feed: "https://www.dr.dk/nyheder/service/feeds/penge")
      end
      # get_feed if @dashboard
    end

    # Only allow a list of trusted parameters through.
    def resource_params
      params.expect(dashboard: [ :tenant_id, :feed, :last_feed, :last_feed_at ])
    end

    def get_feed
      return if @dashboard.last_feed && @dashboard.last_feed_at > 4.hour.ago
      # feed = Feedjira::Feed.fetch_and_parse(dashboard.feed)
      # feed.entries.first.summary
      require "rss"
      require "open-uri"
      rss = URI.open(@dashboard.feed)
      if rss
        @dashboard.update(last_feed_at: Time.now, last_feed: File.read(rss))
      end
    end

    def quotes
      {
        "quotes": [
        {
        "quote": "Take care of the minutes and the hours will take care of themselves.",
        "author": "Lord Chesterfield"
        },
        {
        "quote": "Lost time is never found again.",
        "author": "Benjamin Franklin"
        },
        {
        "quote": "This is the key to time management - to see the value of every moment.",
        "author": "Menachem Mendel Schneerson"
        },
        {
        "quote": "Time management requires self-discipline, self-mastery and self-control more than anything else.",
        "author": "Brian Tracy"
        },
        {
        "quote": "The bad news is time flies. The good news is you're the pilot.",
        "author": "Michael Altshuler"
        },
        {
        "quote": "Time management is life management.",
        "author": "Robin Sharma"
        },
        {
        "quote": "Time is really the only capital that any human being has, and the only thing he can't afford to lose.",
        "author": "Thomas Edison"
        },
        {
        "quote": "Either you run the day, or the day runs you.",
        "author": "Jim Rohn"
        },
        {
        "quote": "Tomorrow belongs to those who prepare for it today.",
        "author": "African Proverb"
        },
        {
        "quote": "We become what we want to be by consistently being what we want to become each day.",
        "author": "Richard G. Scott"
        },
        {
        "quote": "You will never 'find' time for anything. If you want time, you must make it.",
        "author": "Charles Buxton"
        },
        {
        "quote": "In truth, people can generally make time for what they choose to do; it is not really the time but the will that is lacking.",
        "author": "Sir John Lubbock"
        },
        {
        "quote": "Time is the coin of your life. It is the only coin you have, and only you can determine how it will be spent. Be careful lest you let other people spend it for you.",
        "author": "Carl Sandburg"
        },
        {
        "quote": "Never leave 'til tomorrow which you can do today.",
        "author": "Benjamin Franklin"
        },
        {
        "quote": "A year from now you will wish you had started today.",
        "author": "Karen Lamb"
        },
        {
        "quote": "Think ahead. Don't let day-to-day operations drive out planning.",
        "author": "Donald Rumsfeld"
        },
        {
        "quote": "Give me six hours to chop down a tree and I will spend the first four sharpening the axe.",
        "author": "Abraham Lincoln"
        },
        {
        "quote": "One reason so few of us achieve what we truly want is that we never direct our focus; we never concentrate our power. Most people dabble their way through life, never deciding to master anything in particular.",
        "author": "Tony Robbins"
        },
        {
        "quote": "Time has no meaning in itself unless we choose to give it significance.",
        "author": "Leo Buscaglia"
        },
        {
        "quote": "He who every morning plans the transaction of the day and follows out the plan, carries a thread that will guide him through the labyrinth of the most busy life.",
        "author": "Victor Hugo"
        },
        {
        "quote": "If you want to make good use of your time, you've got to know what's most important and then give it all you've got.",
        "author": "Lee Iacocca"
        },
        {
        "quote": "The idea is to make decisions and act on them — to decide what is important to accomplish, to decide how something can best be accomplished, to find time to work at it and to get it done.",
        "author": "Karen Kakascik"
        },
        {
        "quote": "One thing you can't recycle is wasted time.",
        "author": "Anonymous"
        },
        {
        "quote": "One worthwhile task carried to a successful conclusion is worth half-a-hundred half-finished tasks.",
        "author": "Malcolm S. Forbes"
        },
        {
        "quote": "To choose time is to save time.",
        "author": "Francis Bacon"
        },
        {
        "quote": "Time = life; therefore, waste your time and waste of your life, or master your time and master your life.",
        "author": "Alan Lakein"
        },
        {
        "quote": "I must govern the clock, not be governed by it.",
        "author": "Golda Meir"
        },
        {
        "quote": "He who lets time rule him will live the life of a slave.",
        "author": "John Arthorne"
        },
        {
        "quote": "Until we can manage time, we can manage nothing else.",
        "author": "Peter F. Drucker"
        },
        {
        "quote": "One must learn a different sense of time, one that depends more on small amounts than big ones.",
        "author": "Sister Mary Paul"
        },
        {
        "quote": "It's how we spend our time here and now, that really matters. If you are fed up with the way you have come to interact with time, change it.",
        "author": "Marcia Wieder"
        },
        {
        "quote": "This time, like all times, is a very good one, if we but know what to do with it.",
        "author": "Ralph Waldo Emerson"
        },
        {
        "quote": "Time is what we want most, but what we use worst.",
        "author": "William Penn"
        },
        {
        "quote": "Time is a created thing. To say 'I don't have time' is like saying 'I don't want to.'",
        "author": "Lao Tzu"
        },
        {
        "quote": "Time is the wisest counselor of all.",
        "author": "Pericles"
        },
        {
        "quote": "Time is the most valuable thing a man can spend.",
        "author": "Theophrastus"
        },
        {
        "quote": "Time is money.",
        "author": "Benjamin Franklin"
        },
        {
        "quote": "Time is the school in which we learn, time is the fire in which we burn.",
        "author": "Delmore Schwartz"
        },
        {
        "quote": "Time is a great healer, but a poor beautician.",
        "author": "Lucille S. Harper"
        },
        {
        "quote": "Time is the longest distance between two places.",
        "author": "Tennessee Williams"
        },
        {
        "quote": "Time is an illusion.",
        "author": "Albert Einstein"
        },
        {
        "quote": "Time is a dressmaker specializing in alterations.",
        "author": "Faith Baldwin"
        },
        {
        "quote": "Time is the most valuable coin in your life. You and you alone will determine how that coin will be spent.",
        "author": "Carl Sandburg"
        },
        {
        "quote": "Time is the most valuable resource we have, yet we often waste it.",
        "author": "Unknown"
        },
        {
        "quote": "Time is the only thing we can't get back.", "author": "Unknown"
        },
        {
        "quote": "Time is the most precious gift we can give.", "author": "Unknown"
        },
        {
        "quote": "Time is the most important thing in life.", "author": "Unknown"
        },
        {
        "quote": "Time is the most valuable asset we have.", "author": "Unknown"
        },
        {
        "quote": "Time is the most important resource we have.", "author": "Unknown"
        },
        {
        "quote": "Time is the most valuable thing we can spend.", "author": "Unknown"
        },
        {
        "quote": "Time is the most precious commodity we have.", "author": "Unknown"
        },
        {
        "quote": "Time is the most valuable investment we can make.", "author": "Unknown"
        },
        {
        "quote": "Time is the most important investment we can make.", "author": "Unknown"
        }
        ]
        }
    end
end
