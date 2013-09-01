 
class Shoes
    class Element < Shoes
    
    def clear
            send_js %Q~#{self.jqid}.remove()~
        end
        
        def click(&block)
            enable('click', 'click', block)
        end
        
        def double_click(&block)
            enable('double_click', 'dblclick', block)
        end
        
        def enter(&block)
            enable('enter', 'mouseenter', block)
        end
        
        def hide
            send_js %Q~#{self.jqid}.css('visibility', 'hidden')~
        end
        
        def hover(&block)
            enable('hover', 'hover', block)
        end
        
        def leave(&block)
            enable('leave', 'mouseleave', block)
        end
        
        def mouse_up(&block)
            enable('mouse_up', 'mouseup', block)
        end
        
        def mouse_down(&block)
            enable('mouse_down', 'mousedown', block)
        end
        
        def mouse_move(&block)
            enable('mouse_move', 'mousemove', block)
        end
        
        def move(x, y)
            self.left(x); self.top(y)
        end
        
        def rotation(el, axis, degs, xx, yy)  #make this private
            unless xx == 0.5 && yy == 0.5
                x = "#{xx * 100}%";  y = "#{yy * 100}%"
                send_js %Q~#{el.jqid}.css('-webkit-transform-origin', '#{x}% #{y}%').css('-moz-transform-origin', '#{x}% #{y}%').css('-ms-transform-origin', '#{x}% #{y}%').css('-o-transform-origin', '#{x}% #{y}%').css('transform-origin', '#{x}% #{y}%')~
            end
            send_js %Q~#{el.jqid}.css('-webkit-transform', 'rotate#{axis}(' + #{degs} + 'deg)').css('-moz-transform', 'rotate#{axis}(' + #{degs} + 'deg)').css('-ms-transform', 'rotate#{axis}(' + #{degs} + 'deg)').css('-o-transform', 'rotate#{axis}(' + #{degs} + 'deg)').css('transform', 'rotate#{axis}(' + #{degs} + 'deg)')~
        end
        
        def rotate(degs, x=0.5, y=0.5)
            rotation(self, nil, degs, x, y)
        end
        
        def rotate_x(degs, x=0.5, y=0.5)
            rotation(self, 'X', degs, x, y)
        end
        
        def rotate_y(degs, x=0.5, y=0.5)
            rotation(self, 'Y', degs, x, y)
        end
        
        def rotate_z(degs, x=0.5, y=0.5)
            rotation(self, 'Z', degs, x, y)
        end
        
        def show
            send_js %Q~#{self.jqid}.css('visibility', 'visible')~
        end
        
        def toggle(block1, block2)  #### not implemented yet
            b1 = Proc.new{block1}
            b2 = Proc.new{block2}
            p b1, b2
        end
    
 end  # Shoes::Element
end # Shoes