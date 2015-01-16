
# suppress \
#     gen_id <gid>, sig_id <sid>
# 
# suppress \
#     gen_id <gid>, sig_id <sid>, \
#     track by_src|by_dst, \
#     ip <ip-list>
#   Note: ip can be 1.2.3.4 or 1.2.4.5/32

# Create a Standard Error Wrapper

module Threshold

  class InvalidSuppressionObject < StandardError; end

  # Create a Suppression validator
  class SuppressionValidator
      include Veto.validator

      #validates :comment, :cstring => true
      validates :comment, :format => /^#.*/

      validates :gid, :presence => true, :integer => true
      validates :sid, :presence => true, :integer => true

      validates :track_by, :presence => true, :if => :ip_set?, :inclusion => ['src', 'dst']
      validates :ip, :presence => true, :if => :track_by_set?, :format => /^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]).){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\/([1-9]|[1-2][0-9]|3[0-2]))?$/



      def track_by_set?(entity)
          entity.track_by
      end

      def ip_set?(entity)
          entity.ip
      end
  end

  class Suppression 

  	attr_accessor :gid, :sid, :track_by, :ip, :comment

    include Veto.model(SuppressionValidator.new)
    include Comparable

    def initialize(line="")
      @comment = "#" # Set comment to a string by default
      parse unless line.empty?
    end

    #Comparable
    def <=>(anOther)
      gid <=> anOther.gid
    end

  	def to_s
      if self.valid?
    		if track_by == nil then
          if @comment.length < 2
    		    "suppress gen_id #{@gid}, sig_id #{@sid}"
          else
            "suppress gen_id #{@gid}, sig_id #{@sid} #{@comment}"
          end  
    		else
    		  if @comment.length < 2
            "suppress gen_id #{@gid}, sig_id #{@sid}, track by_#{@track_by}, ip #{@ip}"
          else
            "suppress gen_id #{@gid}, sig_id #{@sid}, track by_#{@track_by}, ip #{@ip} #{@comment}"
          end  
    		end
      else
        raise InvalidSuppressionObject, 'Object did not validate'
      end
  	end

    private

    def parse
      ### DO MAGIC!! 
      #grok-native? 
    end



  end

end