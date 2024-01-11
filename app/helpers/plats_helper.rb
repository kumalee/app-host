require_relative '../../lib/parsers/pkg_adapter'

module PlatsHelper
  def pkg_selectable_map
    PkgAdapter.config.adapters.map{|k,v|{v[:des] => k}}.inject(:merge)
  end
end

