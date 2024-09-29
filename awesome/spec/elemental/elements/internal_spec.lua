
local internal_es = require("elemental.elements.internal")
local extension = require("elemental.extension")
local ttable = require("tools.table")
local etypes = require("elemental.types")
local el = require("elemental.elements.el")
local horizontal = require("elemental.elements.horizontal")
local vertical = require("elemental.elements.vertical")
local unveil = require("tools.unveil")

local function _make_elem(args)
    local ext = extension.new({})
    ttable.override_b_to_a(ext, args)
    return ext
end

describe("elemental.elements.internal", function()



    describe("calculate_minimum_dimensions_horizontal", function()

        it("should work when children have size specified in pixels.", function()

            local width = 100
            local height = 100

            local parent = _make_elem({
                _make_elem({
                    width = width,
                    height = height,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == width)
            assert(min_h == height)
        end)

        it("should work when children have size specified as 'etypes.SIZE_FILL'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when children have size specified as 'etypes.SIZE_SHRINK'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has padding.", function()

            local parent = _make_elem({
                padding = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has spacing, but no children.", function()

            local parent = _make_elem({
                spacing = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has spacing, and one child.", function()

            local parent = _make_elem({
                spacing = 10,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has spacing, and more than one child.", function()

            local parent = _make_elem({
                spacing = 10,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                }),
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)

            assert(min_w == 10)
            assert(min_h == 0)
        end)

        it("should work when the element has border_width", function()

            local parent = _make_elem({
                border_width = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has nested children, padding, spacing, and border_width", function()

            local parent = _make_elem({
                border_width = 10,
                padding = etypes.padding_axis({x = 6}),
                spacing = 3,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    border_width = 4,
                    _make_elem({
                        width = 25,
                        height = 40,
                    })
                }),
                _make_elem({
                    width = 25,
                    height = 40,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_horizontal(parent, 0, 0)
            assert(min_w == 93)
            assert(min_h == 68)
        end)
    end)



    describe("calculate_minimum_dimensions_vertical", function()

        it("should work when children have size specified in pixels.", function()

            local width = 100
            local height = 100

            local parent = _make_elem({
                _make_elem({
                    width = width,
                    height = height,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == width)
            assert(min_h == height)
        end)

        it("should work when children have size specified as 'etypes.SIZE_FILL'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when children have size specified as 'etypes.SIZE_SHRINK'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has padding.", function()

            local parent = _make_elem({
                padding = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has spacing, but no children.", function()

            local parent = _make_elem({
                spacing = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has spacing, and one child.", function()

            local parent = _make_elem({
                spacing = 10,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has spacing, and more than one child.", function()

            local parent = _make_elem({
                spacing = 10,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                }),
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)

            assert(min_w == 0)
            assert(min_h == 10)
        end)

        it("should work when the element has border_width", function()

            local parent = _make_elem({
                border_width = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has nested children, padding, spacing, and border_width", function()

            local parent = _make_elem({
                border_width = 10,
                padding = etypes.padding_axis({y = 6}),
                spacing = 3,
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    border_width = 4,
                    _make_elem({
                        width = 25,
                        height = 40,
                    })
                }),
                _make_elem({
                    width = 25,
                    height = 40,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_vertical(parent, 0, 0)
            assert(min_w == 53)
            assert(min_h == 123)
        end)
    end)



    describe("calculate_minimum_dimensions_el", function()

        it("should work when children have size specified in pixels.", function()

            local width = 100
            local height = 100

            local parent = _make_elem({
                _make_elem({
                    width = width,
                    height = height,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == width)
            assert(min_h == height)
        end)

        it("should work when children have size specified as 'etypes.SIZE_FILL'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_FILL,
                    height = etypes.SIZE_FILL
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when children have size specified as 'etypes.SIZE_SHRINK'.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == 0)
            assert(min_h == 0)
        end)

        it("should work when the element has padding.", function()

            local parent = _make_elem({
                padding = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has border_width", function()

            local parent = _make_elem({
                border_width = 10,
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == 20)
            assert(min_h == 20)
        end)

        it("should work when the element has nested children, padding, spacing, and border_width", function()

            local parent = _make_elem({
                border_width = 10,
                padding = etypes.padding_axis({y = 6, x = 3}),
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    border_width = 4,
                    _make_elem({
                        width = 25,
                        height = 40,
                    })
                }),
                _make_elem({
                    width = 25,
                    height = 40,
                })
            })
            local min_w, min_h = internal_es.calculate_minimum_dimensions_el(parent, 0, 0)
            assert(min_w == 59)
            assert(min_h == 80)
        end)

    end)



    describe("dimensionate_children_horizontal", function()

        it("should work when the element's children have height in pixels.", function()

            local parent = _make_elem({
                _make_elem({
                    height = 10,
                    border_width = 5,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 0, 0)

            assert(dim[1].height == 20)

        end)

        it("should work when the element's children have height as SIZE_SHRINK.", function()

            local parent = _make_elem({
                _make_elem({
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        border_width = 4,
                        height = 10
                    })
                }),
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 0, 0)

            assert(dim[1].height == 18)

        end)

        it("should work when the element's children have height as SIZE_FILL.", function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    height = etypes.SIZE_FILL,
                    border_width = 4,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                }),
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 0, 100)

            assert(dim[1].height == 92)

        end)

        it("should work when the element's children have width in pixels.", function()

            local parent = _make_elem({
                _make_elem({
                    width = 10,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)

            assert(dim[1].width == 10)
            assert(dim[1].height == 0)

        end)

        it("should work when the element's children have width as SIZE_SHRINK.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        border_width = 4,
                        width = 10
                    })
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)

            assert(dim[1].width == 18)
            assert(dim[1].height == 0)

        end)

        it("should work when the element's children have width as SIZE_FILL.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        -- we need this method here because when the parent of this 
                        -- element is going to ask it "what's your minimum height?"
                        -- this method is going to take into account things like
                        -- border width, padding, etc
                        _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                        padding = 4,
                        width = 10
                    })
                }),
                _make_elem({
                    width = etypes.SIZE_FILL,
                    height = 40,
                    border_width = 7,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 200, 100)

            assert(dim[1].width == 18)
            assert(dim[1].height == 8)

            -- 182 because in the case of fill-width children, the border actually 
            -- takes space INSIDE the element's available space
            assert(dim[2].width == 182)
            -- 54 because the child's height is in pixels, and the border width
            -- now makes this child take extra height
            assert(dim[2].height == 54)

        end)

        it("should allocate enough space for fill-width children that have padding, spacing, and border_width, but don't have enough space for their content.", function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = etypes.SIZE_FILL,
                    height = 40,

                    border_width = 7,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 22, 0)

            assert(dim[1].width == 14)
            assert(dim[1].height == 54)

        end)

        it( [[\
            * enough room
            * no pushing
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_left
                }
            => .position_type == POSITION_START
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 30,
                    height = 40,
                    border_width = 7,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 30,
                    height = 40,
                    border_width = 3,
                    halign = etypes.ALIGN_LEFT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START)

        end)

        it([[\
            * enough room
            * no pushing
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_right
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 30,
                    height = 40,
                    border_width = 7,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 30,
                    height = 40,
                    border_width = 3,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START_END)

        end)

        it([[\
            * enough room
            * no pushing
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_center
                }
                3:{
                    * halign_right
                }
            => .position_type == POSITION_START_CENTER_END
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 7,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 7,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 3,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START_CENTER_END)
            assert(dim.halign_center_child_id == 2)
            assert(dim.first_halign_right_child_id == 3)
            assert(dim.center_element_x == (2^32 - dim[2].width) / 2)

        end)

        it([[\
            * enough room
            * left side pushes center
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_center
                }
                3:{
                    * halign_right
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 50,
                    height = 30,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_END)
            assert(dim.first_halign_right_child_id == 3)
        end)

        it([[\
            * enough room
            * left side pushes center and right side
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_center
                }
                3:{
                    * halign_right
                }
            => .position_type == POSITION_START
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 100,
                    height = 30,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START)
        end)

        it([[\
            * enough room
            * right side pushes center element
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_center
                }
                3:{
                    * halign_right
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 42,
                    height = 30,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_END)
        end)

        it([[\
            * enough room
            * only center element and right-halign elements
            * children:
                1:{
                    * halign_center
                }
                2:{
                    * halign_right
                }
            => .position_type == POSITION_START_CENTER_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_CENTER_END)
            assert(dim.halign_center_child_id == 1)
            assert(dim.first_halign_right_child_id == 2)
            assert(dim.center_element_x == ((100 - 20) / 2))
        end)

        it([[\
            * not enough room
            * children:
                1:{
                    * halign_left
                }
                2:{
                    * halign_center
                }
                3:{
                    * halign_right
                }
            => .position_type == POSITION_START_CENTER_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_LEFT,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 20,
                    height = 30,
                    halign = etypes.ALIGN_RIGHT,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 0, 0)
            assert(dim.position_type == internal_es.POSITION_START)

        end)

    end)



    describe("dimensionate_children_vertical", function()

        it("should work when the element's children have width in pixels.", function()

            local parent = _make_elem({
                _make_elem({
                    width = 10,
                    border_width = 5,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 0, 0)

            assert(dim[1].width == 20)

        end)

        it("should work when the element's children have width as SIZE_SHRINK.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        border_width = 4,
                        width = 10
                    })
                }),
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 0, 0)

            assert(dim[1].width == 18)

        end)

        it("should work when the element's children have width as SIZE_FILL.", function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = etypes.SIZE_FILL,
                    border_width = 4,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                }),
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 100, 0)

            assert(dim[1].width == 92)

        end)

        it("should work when the element's children have height in pixels.", function()

            local parent = _make_elem({
                _make_elem({
                    height = 10,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)

            assert(dim[1].width == 0)
            assert(dim[1].height == 10)

        end)

        it("should work when the element's children have height as SIZE_SHRINK.", function()

            local parent = _make_elem({
                _make_elem({
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        border_width = 4,
                        height = 10
                    })
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)

            assert(dim[1].width == 0)
            assert(dim[1].height == 18)

        end)

        it("should work when the element's children have height as SIZE_FILL.", function()

            local parent = _make_elem({
                _make_elem({
                    width = etypes.SIZE_SHRINK,
                    height = etypes.SIZE_SHRINK,
                    _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                    _make_elem({
                        -- we need this method here because when the parent of 
                        -- this element is going to ask it "what's your minimum 
                        -- height?" this method is going to be called and take 
                        -- into account things like border width, padding, etc
                        _calculate_minimum_dimensions = internal_es.calculate_minimum_dimensions_el,
                        padding = 4,
                        height = 10
                    })
                }),
                _make_elem({
                    height = etypes.SIZE_FILL,
                    width = 40,
                    border_width = 7,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 200, 100)

            assert(dim[1].width == 8)
            assert(dim[1].height == 18)

            -- 54 because the child's height is in pixels, and the border width
            -- now makes this child take extra height
            assert(dim[2].width == 54)
            -- 82 because in the case of fill-width children, the border actually 
            -- takes space INSIDE the element's available space
            assert(dim[2].height == 82)

        end)

        it("should allocate enough space for fill-height children that have padding, spacing, and border_width, but don't have enough space for their content.", function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    height = etypes.SIZE_FILL,
                    width = 40,
                    border_width = 7,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 0, 0)

            assert(dim[1].width == 54)
            assert(dim[1].height == 14)

        end)

        it( [[\
            * enough room
            * no pushing
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_top
                }
            => .position_type == POSITION_START
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 40,
                    height = 30,
                    border_width = 7,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 40,
                    height = 30,
                    border_width = 3,
                    valign = etypes.ALIGN_TOP,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START)

        end)

        it([[\
            * enough room
            * no pushing
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_bottom
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 40,
                    height = 30,
                    border_width = 7,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 40,
                    height = 30,
                    border_width = 3,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START_END)

        end)

        it([[\
            * enough room
            * no pushing
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_center
                }
                3:{
                    * valign_bottom
                }
            => .position_type == POSITION_START_CENTER_END
        ]], function()

            local parent = _make_elem({
                padding = 4,
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 7,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 7,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 30,
                    border_width = 3,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 2^32, 2^32)
            assert(dim.position_type == internal_es.POSITION_START_CENTER_END)
            assert(dim.valign_center_child_id == 2)
            assert(dim.first_valign_bottom_child_id == 3)
            assert(dim.center_element_y == (2^32 - dim[2].height) / 2)
        end)

        it([[\
            * enough room
            * top side pushes center
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_center
                }
                3:{
                    * valign_bottom
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 30,
                    height = 50,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_END)
            assert(dim.first_valign_bottom_child_id == 3)
        end)

        it([[\
            * enough room
            * top side pushes center and bottom side
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_center
                }
                3:{
                    * valign_bottom
                }
            => .position_type == POSITION_START
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 30,
                    height = 100,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_horizontal(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START)
        end)

        it([[\
            * enough room
            * bottom side pushes center element
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_center
                }
                3:{
                    * valign_bottom
                }
            => .position_type == POSITION_START_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 42,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_END)
        end)

        it([[\
            * enough room
            * only center element and bottom-valign elements
            * children:
                1:{
                    * valign_center
                }
                2:{
                    * valign_bottom
                }
            => .position_type == POSITION_START_CENTER_END
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 100, 100)
            assert(dim.position_type == internal_es.POSITION_START_CENTER_END)
            assert(dim.valign_center_child_id == 1)
            assert(dim.first_valign_bottom_child_id == 2)
            assert(dim.center_element_y == ((100 - 20) / 2))
        end)

        it([[\
            * not enough room
            * children:
                1:{
                    * valign_top
                }
                2:{
                    * valign_center
                }
                3:{
                    * valign_bottom
                }
            => .position_type == POSITION_START
        ]], function()

            local parent = _make_elem({
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_TOP,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_CENTER,
                }),
                _make_elem({
                    width = 30,
                    height = 20,
                    valign = etypes.ALIGN_BOTTOM,
                })
            })

            local dim = internal_es.dimensionate_children_vertical(parent, 0, 0)
            assert(dim.position_type == internal_es.POSITION_START)

        end)

    end)

    describe("position_children_horizontal", function()

        --TODO

    end)





end)

