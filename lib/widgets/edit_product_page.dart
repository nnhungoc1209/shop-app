import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/product.dart';
import 'package:shop_app/providers/products_provider.dart';

class EditProductPage extends StatefulWidget {
  const EditProductPage({Key? key}) : super(key: key);

  static const routeName = '/edit-product';

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _priceFocudNode = FocusNode();
  final _descriptonFocudNode = FocusNode();
  final _imageUrlFocudNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProuct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: ''
  );

  var _initValues = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };

  var _isInit = true;
  var _isLoading = false;
  
  @override
  void initState() {
    _imageUrlFocudNode.addListener(_updateImageURL);
    super.initState();
  }

  @override
  void didChangeDependencies() {
     if (_isInit) {
       if (ModalRoute.of(context)!.settings.arguments != null) {
         final productId = ModalRoute.of(context)!.settings.arguments as String;
         _editedProuct = Provider.of<ProductsProvider>(context).findById(productId);
         _initValues = {
           'title': _editedProuct.title,
           'description': _editedProuct.description,
           'price': _editedProuct.price.toString(),
           //'imageUrl': _editedProuct.imageUrl,
           'imageUrl': '',
         };
         _imageUrlController.text = _editedProuct.imageUrl;
       }
     }
     _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _priceFocudNode.dispose();
    _descriptonFocudNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocudNode.dispose();
    _imageUrlFocudNode.removeListener(_updateImageURL);
    super.dispose();
  }

  void _updateImageURL() {
    if (!_imageUrlFocudNode.hasFocus) {
      if ((!_imageUrlController.text.startsWith('http') &&
           !_imageUrlController.text.startsWith('https')) ||
           (!_imageUrlController.text.endsWith('.png') &&
           !_imageUrlController.text.endsWith('.jpg') &&
           !_imageUrlController.text.endsWith('jpeg'))) {
        return;
      }

      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProuct.id != '') {
      await Provider.of<ProductsProvider>(context, listen: false).updateProduct(_editedProuct.id, _editedProuct);

      Navigator.of(context).pop();
    } else {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProuct);
      } catch (error) {
        await showDialog<Null>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('An error occurred!'),
            content: const Text('Something went wrong.'),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  print('Pop - OK');
                  Navigator.of(context).pop();
                }
              )
            ],
          )
        );
      }
      // finally {
      //   setState(() {
      //     _isLoading = false;
      //   });
      //
      //   print('Pop - setState');
      //   Navigator.of(context).pop();
      // }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
        ?  const Center(
        child: CircularProgressIndicator(),
      )
        : Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    initialValue: _initValues['title'],
                    decoration: const InputDecoration(
                      label: Text('Title'),
                    ),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_priceFocudNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Title is required';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProuct = Product(
                        id: _editedProuct.id,
                        title: value ?? '',
                        price: 0,
                        description: '',
                        imageUrl: '',
                        isFavorite: _editedProuct.isFavorite
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'],
                    decoration: const InputDecoration(
                      label: Text('Price'),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocudNode,
                    onFieldSubmitted: (_) {
                      FocusScope.of(context).requestFocus(_descriptonFocudNode);
                    },
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'The price is required.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number greater than zero';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProuct = Product(
                        id: _editedProuct.id,
                        title: _editedProuct.title,
                        price: double.parse(value!),
                        description: '',
                        imageUrl: '',
                        isFavorite: _editedProuct.isFavorite
                      );
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'],
                    decoration: const InputDecoration(
                      label: Text('Description'),
                    ),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptonFocudNode,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'The price is required.';
                      }
                      if (value.length < 10) {
                        return 'Should be at least 10 characters long.';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _editedProuct = Product(
                        id: _editedProuct.id,
                        title: _editedProuct.title,
                        price: _editedProuct.price,
                        description: value ?? '',
                        imageUrl: '',
                        isFavorite: _editedProuct.isFavorite
                      );
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100.0,
                        height: 100.0,
                        margin: const EdgeInsets.only(top: 8.0, right: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1.0,
                            color: Colors.grey,
                          )
                        ),
                        child: _imageUrlController.text.isEmpty
                          ? const Text('Enter URL...')
                          : FittedBox(
                            child: Image.network(
                              _imageUrlController.text,
                              fit: BoxFit.cover,
                            ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            label: Text('Image URL'),
                          ),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocudNode,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Image URL is required.';
                            }
                            if (!value.startsWith('http') && !value.startsWith('https')) {
                              return 'Please enter a valid URL';
                            }
                            if (!value.endsWith('.png') && !value.endsWith('jpg') && !value.endsWith('jpeg')) {
                              return 'Please enter a valid image URL';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _editedProuct = Product(
                              id: _editedProuct.id,
                              title: _editedProuct.title,
                              price: _editedProuct.price,
                              description: _editedProuct.description,
                              imageUrl: value ?? '',
                              isFavorite: _editedProuct.isFavorite
                            );
                          },
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
      ),
    );
  }
}
