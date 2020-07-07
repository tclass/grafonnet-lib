{
  /**
   * Creates a [stat panel](https://grafana.com/docs/grafana/latest/panels/visualizations/stat-panel/).
   *
   * @name stat.new
   *
   * @param title Panel title.
   * @param description Panel description.
   * @param transparent Whether to display the panel without a background.
   * @param datasource Panel datasource.
   * @param allValues Show all values instead of reducing to one.
   * @param valueLimit Limit of values in all values mode.
   * @param reducerFunction Function to use to reduce values to when using single value.
   * @param fields Fields that should be included in the panel.
   * @param orientation Stacking direction in case of multiple series or fields.
   * @param colorMode 'value' or 'background'.
   * @param graphMode 'none' or 'area' to enable sparkline mode.
   * @param justifyMode 'auto' or 'center'.
   * @param unit Panel unit field option.
   * @param min Leave empty to calculate based on all values.
   * @param max Leave empty to calculate based on all values.
   * @param decimals Number of decimal places to show.
   * @param displayName Change the field or series name.
   * @param noValue What to show when there is no value.
   * @param thresholdsMode 'absolute' or 'percentage'.
   * @param repeat Name of variable that should be used to repeat this panel.
   * @param repeatDirection 'h' for horizontal or 'v' for vertical.
   * @param repeatMaxPerRow Maximum panels per row in repeat mode.
   * @param pluginVersion Plugin version the panel should be modeled for. This has been tested with the default, '7', and '6.7'.
   *
   * @method addTarget(target) Adds a target object.
   * @method addTargets(targets) Adds an array of targets.
   * @method addLink(link) Adds a link. Aregument format: `{ title: 'Link Title', url: 'https://...', targetBlank: true }`.
   * @method addLinks(links) Adds an array of links.
   * @method addThreshold(step) Adds a threshold step. Aregument format: `{ color: 'green', value: 0 }`.
   * @method addThresholds(steps) Adds an array of threshold steps.
   * @method addMapping(mapping) Adds a value mapping.
   * @method addMappings(mappings) Adds an array of value mappings.
   * @method addDataLink(link) Adds a data link.
   * @method addDataLinks(links) Adds an array of data links.
   */
  new(
    title,
    description=null,
    transparent=false,
    datasource=null,
    allValues=false,
    valueLimit=null,
    reducerFunction='mean',
    fields='',
    orientation='auto',
    colorMode='value',
    graphMode='area',
    justifyMode='auto',
    unit='none',
    min=null,
    max=null,
    decimals=null,
    displayName=null,
    noValue=null,
    thresholdsMode='absolute',
    repeat=null,
    repeatDirection='h',
    repeatMaxPerRow=null,
    pluginVersion='7',
  ):: {

    type: 'stat',
    title: title,
    [if description != null then 'description']: description,
    transparent: transparent,
    datasource: datasource,
    targets: [],
    links: [],
    [if repeat != null then 'repeat']: repeat,
    [if repeat != null then 'repeatDirection']: repeatDirection,
    [if repeat != null then 'repeatMaxPerRow']: repeatMaxPerRow,

    // targets
    _nextTarget:: 0,
    addTarget(target):: self {
      local nextTarget = super._nextTarget,
      _nextTarget: nextTarget + 1,
      targets+: [target { refId: std.char(std.codepoint('A') + nextTarget) }],
    },
    addTargets(targets):: std.foldl(function(p, t) p.addTarget(t), targets, self),

    // links
    addLink(link):: self {
      links+: [link],
    },
    addLinks(links):: std.foldl(function(p, l) p.addLink(l), links, self),

    pluginVersion: pluginVersion,
  } + (

    if pluginVersion >= '7' then {
      options: {
        reduceOptions: {
          values: allValues,
          [if allValues && valueLimit != null then 'limit']: valueLimit,
          calcs: [
            reducerFunction,
          ],
          fields: fields,
        },
        orientation: orientation,
        colorMode: colorMode,
        graphMode: graphMode,
        justifyMode: justifyMode,
      },
      fieldConfig: {
        defaults: {
          unit: unit,
          [if min != null then 'min']: min,
          [if max != null then 'max']: max,
          [if decimals != null then 'decimals']: decimals,
          [if displayName != null then 'displayName']: displayName,
          [if noValue != null then 'noValue']: noValue,
          thresholds: {
            mode: thresholdsMode,
            steps: [],
          },
          mappings: [],
          links: [],
        },
      },

      // thresholds
      addThreshold(step):: self {
        fieldConfig+: { defaults+: { thresholds+: { steps+: [step] } } },
      },

      // mappings
      _nextMapping:: 0,
      addMapping(mapping):: self {
        local nextMapping = super._nextMapping,
        _nextMapping: nextMapping + 1,
        fieldConfig+: { defaults+: { mappings+: [mapping { id: nextMapping }] } },
      },

      // data links
      addDataLink(link):: self {
        fieldConfig+: { defaults+: { links+: [link] } },
      },
    } else {
      options: {
        fieldOptions: {
          values: allValues,
          [if allValues && valueLimit != null then 'limit']: valueLimit,
          calcs: [
            reducerFunction,
          ],
          fields: fields,
          defaults: {
            unit: unit,
            [if min != null then 'min']: min,
            [if max != null then 'max']: max,
            [if decimals != null then 'decimals']: decimals,
            [if displayName != null then 'displayName']: displayName,
            [if noValue != null then 'noValue']: noValue,
            thresholds: {
              mode: thresholdsMode,
              steps: [],
            },
            mappings: [],
            links: [],
          },
        },
        orientation: orientation,
        colorMode: colorMode,
        graphMode: graphMode,
        justifyMode: justifyMode,
      },

      // thresholds
      addThreshold(step):: self {
        options+: { fieldOptions+: { defaults+: { thresholds+: { steps+: [step] } } } },
      },

      // mappings
      _nextMapping:: 0,
      addMapping(mapping):: self {
        local nextMapping = super._nextMapping,
        _nextMapping: nextMapping + 1,
        options+: { fieldOptions+: { defaults+: { mappings+: [mapping { id: nextMapping }] } } },
      },

      // data links
      addDataLink(link):: self {
        options+: { fieldOptions+: { defaults+: { links+: [link] } } },
      },
    }

  ) + {
    addThresholds(steps):: std.foldl(function(p, s) p.addThreshold(s), steps, self),
    addMappings(mappings):: std.foldl(function(p, m) p.addMapping(m), mappings, self),
    addDataLinks(links):: std.foldl(function(p, l) p.addDataLink(l), links, self),
  },
}
