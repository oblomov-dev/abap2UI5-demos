CLASS z2ui5_cl_app_demo_68 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES z2ui5_if_app.

    TYPES:
      BEGIN OF ty_prodh_node_level3,
        is_selected TYPE abap_bool,
        text        TYPE string,
        prodh       TYPE string,
      END OF ty_prodh_node_level3,
      BEGIN OF ty_prodh_node_level2,
        is_selected TYPE abap_bool,
        text        TYPE string,
        prodh       TYPE string,
        nodes       TYPE STANDARD TABLE OF ty_prodh_node_level3 WITH DEFAULT KEY,
      END OF ty_prodh_node_level2,
      BEGIN OF ty_prodh_node_level1,
        is_selected TYPE abap_bool,
        text        TYPE string,
        prodh       TYPE string,
        nodes       TYPE STANDARD TABLE OF ty_prodh_node_level2 WITH DEFAULT KEY,
      END OF ty_prodh_node_level1,
      ty_prodh_nodes TYPE STANDARD TABLE OF ty_prodh_node_level1 WITH DEFAULT KEY.

    DATA prodh_nodes    TYPE ty_prodh_nodes.
    DATA is_initialized TYPE abap_bool.

  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA client TYPE REF TO z2ui5_if_client.

    METHODS ui5_initialize.
    METHODS ui5_display_popup_tree_select.

ENDCLASS.



CLASS z2ui5_cl_app_demo_68 IMPLEMENTATION.

  METHOD z2ui5_if_app~main.

    me->client = client.

    IF is_initialized = abap_false.
      is_initialized = abap_true.
      ui5_initialize( ).

      client->view_display( z2ui5_cl_xml_view=>factory( client
        )->button( text = 'TEST' press = client->_event( 'POPUP_TREE' )
        )->stringify( ) ).

    ENDIF.

    CASE client->get( )-event.
      WHEN 'POPUP_TREE'.
        ui5_display_popup_tree_select( ).
      WHEN 'CONTINUE'.
        client->popup_destroy( ).
        client->message_box_display( `Selected entry is set in the backend` ).

      WHEN 'CANCEL'.
        client->popup_destroy( ).
    ENDCASE.

  ENDMETHOD.


  METHOD ui5_initialize.
    prodh_nodes =
    VALUE #( ( text = 'Machines'
               prodh = '00100'
               nodes = VALUE #( ( text = 'Pumps'
                                  prodh = '0010000100'
                                  nodes = VALUE #( ( text = 'Displacement pump'
                                                     prodh = '001000010000000100' )
                                                   ( text = 'Centrifugal pump'
                                                     prodh = '001000010000000105' )
                                          )
                       ) )
             )
             ( text = 'Paints'
               prodh = '00110'
               nodes = VALUE #( ( text = 'Gloss paints'
                                  prodh = '0011000105'
                                  nodes = VALUE #( ( text = 'Opaque'
                                                     prodh = '001100010500000100' )
                                                   ( text = 'Clear'
                                                     prodh = '001100010500000105' )
                                          )
                       ) )
             )
    ).
  ENDMETHOD.


  METHOD ui5_display_popup_tree_select.

    DATA(popup) = z2ui5_cl_xml_view=>factory_popup( client ).

    DATA(dialog) = popup->dialog( title         = 'choose prod hier'
                                  contentheight = '50%'
                                  contentwidth  = '50%' ).

    dialog->tree( mode  = 'SingleSelectMaster'
                  items = client->_bind_edit( prodh_nodes )
        )->items(
            )->standard_tree_item( selected = '{IS_SELECTED}'
            title = '{TEXT}'
    ).
    dialog->buttons(
    )->button( text  = 'Continue'
               icon  = `sap-icon://accept` ##NO_TEXT
               type  = `Accept`
               press = client->_event( 'CONTINUE' )
    )->button( text  = 'Cancel'
               icon  = `sap-icon://decline`
               type  = `Reject`
               press = client->_event( 'CANCEL' )
    ).

    client->popup_display( popup->stringify( ) ).

  ENDMETHOD.

ENDCLASS.
