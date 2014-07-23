# Cache some DOM elements
visualizerElement = document.getElementById('visualizer')

# Create a mother grid point element; we'll clone it whenever we need a grid point
gridPointElementMother = document.createElement('div')

# Get a datasource
dataSource = new (getDataSource())

# Attach a handler to that data source, to be called whenever new data is available
dataSource.onData (data) ->
  Perf.time 'reconstructing DOM' if PROFILE

  gridPointElements = visualizerElement.children

  for dataPoint, i in data
    gridPointElement
    if i >= gridPointElements.length
      # Construct a grid point DOM element by cloning the mother
      gridPointElement = gridPointElementMother.cloneNode()
      # Append this grid point to the visualizer
      visualizerElement.appendChild gridPointElement
    else
      # Reuse a node
      gridPointElement = gridPointElements[i]

    # Set its brightness
    if gridPointElement.dataBrightness != dataPoint.brightness
      gridPointElement.dataBrightness = dataPoint.brightness
      gridPointElement.style.backgroundColor = "rgba(0,255,0,#{dataPoint.brightness})"

  # If the grid happened to be bigger than the dataset, trim the DOM back down.
  for _ in [data.length...gridPointElements.length] by 1
    visualizerElement.removeNode visualizerElement.lastChildElement

  Perf.timeEnd 'reconstructing DOM' if PROFILE

# Make the data source work as fast as possible
workIt = ->
  # Work!
  dataSource.doWork()

  # Force a synchronous reflow, then schedule another work package.
  # NOTE: This is preferable to using requestAnimationFrame, because RAF fires at funny times.
  Perf.time 'redrawing' if PROFILE
  forceReflow()
  Perf.timeEnd 'redrawing' if PROFILE

  # Schedule that next work package
  setZeroTimeout workIt
workIt()
